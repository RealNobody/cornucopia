require ::File.expand_path('file_asset', File.dirname(__FILE__))
# require ::File.expand_path('report_builder', File.dirname(__FILE__))

module Cornucopia
  module Util
    class ReportTable
      class ReportTableException < Exception
        attr_accessor :error

        def initialize(error)
          @error = error
        end

        def to_s
          @error.to_s
        end

        def backtrace
          @error.backtrace
        end
      end

      attr_reader :full_table

      # Usage Example:
      #
      # ReportTable.new do |report_table|
      #   report_table.write_stats("label", "value")
      #
      #   ReportTable.new(table_prefix: more_info_prefix_text,
      #       table_postfix: more_info_postfix_text,
      #       nested_table: report_table) do |more_info_block|
      #     ReportTable.new(nested_table: more_info_block) do |more_info_table|
      #       more_info_table.write_stats("label", "value")
      #
      #       ReportTable.new(report_table: is_sub_table? nil : more_info_table,
      #           nested_table: more_info_table) do |sub_table|
      #         sub_table.write_stats("label", "value")
      #       end
      #     end
      #   end
      # end

      # options
      #   table_prefix          - The value to open the table with.
      #                           Default: <div class="cornucopia-table">
      #   table_postfix         - The value to output when closing the table.
      #                           Default: </div>
      #   report_table          - The table that all table cells are to be output
      #                           to.
      #                           If set, this table will effectively not do anything.
      #                           Default: nil
      #   nested_table          - If this table is nested inside of another table, this will ensure
      #                           that the nested table is written, even in case of an exception.
      #   nested_table_label    - The label that the nested table is to be output with.
      #   nested_table_options  - The options that the nested table is to be output with.
      #                           Default: { prevent_shrink: true, exclude_code_block: true, do_not_pretty_print: true }
      #   not_a_table           - If set, then write_stats simply appends the value to the "table"
      #                           Default: false
      #   suppress_blank_table  - If set, then when a nested table is to be written to the parent table, the
      #                           nested table will not be output if it is empty.
      def initialize(options = {}, &block)
        @full_table   = ""
        @table_closed = false
        @options      = options

        @options.delete_if { |key, value| value.blank? }
        @options.reverse_merge!({
                                    table_prefix:         "<div class=\"cornucopia-table\">\n",
                                    table_postfix:        "</div>\n",
                                    report_table:         self,
                                    nested_table:         nil,
                                    nested_table_label:   nil,
                                    nested_table_options: { prevent_shrink:      true,
                                                            exclude_code_block:  true,
                                                            do_not_pretty_print: true }
                                })

        @options[:report_table] ||= self

        begin
          open_table

          block.yield(@options[:report_table]) if block
        rescue ReportTableException => table_error
          if @options[:nested_table]
            raise table_error
          else
            raise table_error.error
          end
        rescue Exception => error
          error_report = "".html_safe
          error_report << error.to_s + "\n"
          error_report << error.class.name + "\n"
          error_report << error.class.name + "\n"
          error_report << Cornucopia::Util::ReportBuilder.pretty_format(error.backtrace)

          @options[:report_table].write_stats "<strong>Exception while building table</strong>".html_safe, error_report

          raise(ReportTableException.new(error))
        ensure
          close_table
        end
      end

      def open_table
        @full_table << @options[:table_prefix] if @options[:table_prefix] && @options[:report_table] == self
        @table_start = @full_table.clone
      end

      def close_table
        empty_table = @table_start == @full_table

        @full_table << @options[:table_postfix] if @options[:table_postfix] && @options[:report_table] == self
        @full_table = @full_table.html_safe

        if @options[:nested_table] && @options[:report_table] != @options[:nested_table]
          if !@options[:suppress_blank_table] || !empty_table
            @options[:nested_table].write_stats(@options[:nested_table_label],
                                                @options[:report_table].full_table,
                                                @options[:nested_table_options])
          end
        else
          unless !@options[:suppress_blank_table] || !empty_table
            @full_table = "".html_safe
          end
        end

        @table_closed = true
      end

      # Writes information to the table.
      #
      # Parameters:
      #   label                 - The label for the information.
      #                           Should be short.  Will be made bold and the cell will be shrunk.
      #   value                 - The value for the information.
      #                           If the value is very wide, the cell will expand to show it.
      #                           If the value is very tall, an expansion option will be provided, and the
      #                           cell will truncate the value otherwise.
      #
      #   options:
      #     prevent_shrink     -  If set, the cell will not be truncated if it is too tall, instead the cell will show
      #                           the full contents.
      #                           default - false
      #     exclude_code_block  - If set, then the <pre><code> tags will not be added to the output
      #                           default: false
      #     do_not_pretty_print - If set, then the value will only be escaped.
      #                           If not, then it will be pretty formatted.
      #                           default: false
      def write_stats label, value, options = {}
        raise Exception.new("The table is closed, you may not add more rows to it") if @table_closed

        if options[:format]
          print_value = options[:format].call(value)
        elsif options[:format_function] && options[:format_object]
          print_value = options[:format_object].send(options[:format_function], value)
        elsif options[:do_not_pretty_print]
          print_value = Cornucopia::Util::ReportBuilder.escape_string(value)
        else
          print_value = Cornucopia::Util::ReportBuilder.pretty_format(value)
        end
        label = Cornucopia::Util::ReportBuilder.escape_string(label)

        unless @options[:not_a_table]
          @full_table << "  <div class=\"cornucopia-row\">\n"
          @full_table << "    <div class=\"cornucopia-cell-label\">\n#{label}\n</div>\n"
          @full_table << "    <div class=\"cornucopia-cell-expand\">\n"
          unless options[:prevent_shrink]
            @full_table << "    <div class=\"hidden\"><a class=\"cornucopia-cell-more-data\" href=\"#\"><img src=\"expand.gif\"></a></div>\n"
          end
          @full_table << "    </div>\n"
          @full_table << "    <div class=\"cornucopia-cell-data\">\n"
          unless options[:prevent_shrink]
            @full_table << "      <div class=\"hide-contents\">\n"
          end

          @full_table << "<pre><code>" unless options[:exclude_code_block]
        end

        @full_table << print_value

        unless @options[:not_a_table]
          @full_table << "</code></pre>\n" unless options[:exclude_code_block]
          unless options[:prevent_shrink]
            @full_table << "      </div>\n"
            @full_table << "      <div class=\"cornucopia-cell-more hidden\"><a class=\"cornucopia-cell-more-data\" href=\"#\">more...</a></div>\n"
          end
          @full_table << "    </div>\n"
          @full_table << "  </div>\n"
        end
      end
    end
  end
end