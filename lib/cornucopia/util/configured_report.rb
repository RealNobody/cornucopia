require ::File.expand_path('report_builder', File.dirname(__FILE__))
require ::File.expand_path('report_table', File.dirname(__FILE__))
require ::File.expand_path('log_capture', File.dirname(__FILE__))
require ::File.expand_path('../capybara/page_diagnostics', File.dirname(__FILE__))

module Cornucopia
  module Util
    class ConfiguredReport
      # ConfiguredReport outputs an error report based on symbol based configurations
      #
      # The configurations are as follows:
      #   min_fields
      #   more_info_fields
      #   expand_fields
      #   expand_inline_fields
      #   exclude_fields
      #   leaf_options
      #
      # min_field
      #   This is a list of the fields which are to be output at the top of the report
      #   such that they are always visible.
      #   Items in the min list which cannot be found will output an error.
      #
      #   If any options are provided in a field that is a non-expanded leaf node, those options will
      #   be used instead of the leaf_options if any.
      #
      # more_info_fields
      #   This is a list of the fields which are to be output below the min fields
      #   in a section that is initially hidden.  The user can expand these values
      #   If/when they need to.
      #   Items in the more info list which cannot be found will output an error.
      #
      #   If any options are provided in a field that is a non-expanded leaf node, those options will
      #   be used instead of the leaf_options if any.
      #
      # expand_fields
      #   This is a list of the fields which are to be expanded when they are encountered.
      #   Expanded fields are shown in a sub-table of values so that the instance variables
      #   are then each output.
      #   items which are to be expanded may be explicitly or implicitly exported.
      #   items which are not encountered but are in the expand list will be ignored.
      #
      #   If any options are provided here, these options will be applied to all expanded items which
      #   are leaf nodes that are not expanded.
      #
      # expand_inline_fields
      #   This is a list of the fields which are to be expanded, but unlike expanded fields
      #   when these items are expanded, they will be placed at the same level as the current
      #   items rather than in a sub-table.
      #
      #   If any options are provided here, these options will be applied to all expanded items which
      #   are leaf nodes that are not expanded.  If a field is specified in both expand and
      #   expand_inline, the options for expand will take precedence over expand_inline.
      #
      # exclude_fields
      #   This is a list of the fields which are not to be output when they are encountered.
      #   There are many implicit ways to output a field (such as the expanded fields).
      #   If a field is to be implicityly exported, it will not be exported if it is in this
      #   list.  A field can always be explicitly exported.  Items not encountered but
      #   in the exclude list will be ignored.
      #
      #   If any options are provided here, they will be ignored.
      #
      # leaf_options
      #   When a leaf node is output, this set is checked to see if there are any options to be passed into the
      #   Cornucopia::Util::ReportTable.write_stats function.
      #   leaf_options is only useful if you provide options.
      #
      #   Unlike the other nodes, leaf_options does not use the field names to specify a full path.
      #   Instead, the leaf options allows an arry of values in the report_element field to specify a list
      #   of leaf fields which all have the same options (if not overridden by the min or more_info lists).
      #
      # field names follow a set pattern:
      #   <object_name>__<function_property_or_hash_name>
      #
      # You can have as many following __<function_or_property_name> values as you need.
      #
      #   OR
      #
      #   { report_element: <field name>, report_options: {<options hash>} }
      #
      # Examples:
      #   self.exception.backtrace would be specified as: :self__exception__backtrace
      #   self.my_hash[:my_key] would be specified as: :self__my_hash__my_key
      #   self.to_s would be specified as: :self__to_s
      #   self.as_text_area may be specified as: { report_element: :self, report_options: { prevent_shrink: true } }
      #
      # There are a handful of special conditions:
      #   if the last_line is to_s, the label that is output will not be to_s, but the previous item level
      #
      # :logs
      #   This will output the logs using Cornucopia::Util::LogCapture.capture_logs
      #   Unlike normal items, if there are no logs to export, this will not generate an error.
      #
      # :capybara_page_diagnostics
      #   This will output Capybara infomration using
      #   Cornucopia::Capybara::Diagnostics.output_page_detail_section.
      #   NOTE:  This option requres a parameter be passed into the report_options for :diagnostics_name
      #   Unlike normal items, if Capybara is not being used, this will not generate an error.

      def initialize(options = {})
        @min_fields           = []
        @more_info_fields     = []
        @expand_fields        = []
        @expand_inline_fields = []
        @exclude_fields       = []
        @leaf_options         = []
        @report_objects       = {}

        self.min_fields           = options[:min_fields]
        self.more_info_fields     = options[:more_info_fields]
        self.expand_fields        = options[:expand_fields]
        self.expand_inline_fields = options[:expand_inline_fields]
        self.exclude_fields       = options[:exclude_fields]
        self.leaf_options         = options[:leaf_options]
        @report                   = options[:report]
      end

      def min_fields=(value)
        @min_fields = split_field_symbols(value)
      end

      def more_info_fields=(value)
        @more_info_fields = split_field_symbols(value)
      end

      def expand_fields=(value)
        @expand_fields = split_field_symbols(value)
      end

      def expand_inline_fields=(value)
        @expand_inline_fields = split_field_symbols(value)
      end

      def exclude_fields=(value)
        @exclude_fields = split_field_symbols(value)
      end

      def leaf_options=(value)
        @leaf_options = split_field_symbols(value)
      end

      def add_report_objects(report_object_hash)
        @report_objects.merge! report_object_hash
      end

      # This function generates the report.
      #
      # Options:
      #   report_table      - If the report is to be run inside an already existing table, the table
      #                       to output the values into.
      #   nested_table      - If the report is running inside an existing table already, the table
      #                       it is running in.
      #                       NOTE:  This value may not be
      #   diagnostics_name  - The text to output when outputing capybara diagnostics if it is not expanded in-line.
      def generate_report(report, options = {}, &block)
        @report = (report ||= Cornucopia::Util::ReportBuilder.current_report)

        options_report_table = options.delete(:report_table)
        [@min_fields, @more_info_fields].each do |export_field_list|
          if export_field_list
            table_pre  = nil
            table_post = nil

            if @min_fields != export_field_list && !options_report_table
              options_report_table = nil

              table_pre = "<div class=\"cornucopia-show-hide-section\">\n"
              table_pre << "  <div class=\"cornucopia-table\">\n"
              table_pre << "    <div class=\"cornucopia-row\">\n"
              table_pre << "      <div class=\"cornucopia-cell-data\">\n"
              table_pre << "        <a class =\"cornucopia-additional-details\" href=\"#\">More Details...</a>\n"
              table_pre << "      </div>\n"
              table_pre << "    </div>\n"
              table_pre << "  </div>\n"
              table_pre << "  <div class=\"cornucopia-additional-details hidden\">\n"
              table_pre.html_safe
              table_post = "  </div>\n"
              table_post << "</div>\n"
              table_post.html_safe
            end

            report.within_table(table_prefix:         table_pre,
                                table_postfix:        table_post,
                                report_table:         options_report_table,
                                nested_table:         options.delete(:nested_table),
                                nested_table_label:   options.delete(:nested_table_label),
                                not_a_table:          table_pre,
                                suppress_blank_table: table_pre) do |outer_report_table|
              Cornucopia::Util::ReportTable.new(
                  report_table:         table_pre ? nil : outer_report_table,
                  nested_table:         outer_report_table,
                  suppress_blank_table: table_pre) do |report_table|
                export_field_list.each do |export_field|
                  if @report_objects[export_field[:report_element][0]] ||
                      export_field[:report_element][0] == :capybara_page_diagnostics ||
                      export_field[:report_element][0] == :logs
                    export_field_record(export_field,
                                        @report_objects[export_field[:report_element][0]],
                                        export_field[:report_element][0],
                                        report_table,
                                        0,
                                        options.merge(report_object_set: true))
                  end
                end

                if block
                  if @min_fields != export_field_list
                    block.yield report, report_table
                  end
                end
              end
            end
          end
        end
      end

      def perform_expansion(export_field, level, sub_vars_report, options, sub_symbol_name, value)
        sub_export_field = { report_element: export_field[:report_element].clone }
        if level == sub_export_field[:report_element].length - 1
          sub_export_field[:report_options] = export_field[:report_options]
        end

        if level == sub_export_field[:report_element].length - 1 ||
            (level < sub_export_field[:report_element].length &&
                sub_export_field[:report_element][level + 1] != sub_symbol_name.to_sym)
          sub_export_field[:report_element] = sub_export_field[:report_element][0..level]
          sub_export_field[:report_element] << sub_symbol_name.to_sym
        end

        export_field_record(sub_export_field,
                            value,
                            sub_symbol_name.to_sym,
                            sub_vars_report,
                            level + 1,
                            options.merge(report_object_set: true, expanded_field: true))
      end

      def expand_field_object(export_field, expand_object, symbol_name, report_table, level, options = {})
        expand_inline = options.delete(:expand_inline)

        Cornucopia::Util::ReportTable.new(report_table:         expand_inline ? report_table : nil,
                                          nested_table:         report_table,
                                          nested_table_label:   symbol_name,
                                          suppress_blank_table: true) do |sub_vars_report|
          if expand_object.is_a?(Hash)
            expand_object.each do |sub_symbol_name, value|
              perform_expansion(export_field, level, sub_vars_report, options, sub_symbol_name, value)
            end
          elsif expand_object.respond_to?(:members)
            key_values = expand_object.members

            key_values.each do |sub_symbol_name|
              perform_expansion(export_field,
                                level,
                                sub_vars_report,
                                options,
                                sub_symbol_name,
                                expand_object.send(sub_symbol_name))
            end
          elsif expand_object.respond_to?(:each)
            each_index = 0
            expand_object.each do |value|
              perform_expansion(export_field, level, sub_vars_report, options, each_index.to_s, value)
              each_index += 1
            end
          else
            expand_object.instance_variable_names.sort.each do |variable_name|
              var_symbol_name = variable_name.to_s
              while var_symbol_name[0] == "@"
                var_symbol_name = var_symbol_name[1..-1]
              end

              # if level == sub_export_field[:report_element].length - 1 ||
              #     (level < sub_export_field[:report_element].length &&
              #         sub_export_field[:report_element][level + 1] != var_symbol_name.to_sym)
              #   sub_export_field[:report_options] = nil
              # end
              perform_expansion(export_field,
                                level,
                                sub_vars_report,
                                options,
                                var_symbol_name,
                                get_instance_variable(expand_object, variable_name, var_symbol_name))
            end
          end
        end
      end

      def instance_variables_contain(parent_object, variable_name)
        found_name = nil

        parent_object.instance_variable_names.any? do |instance_variable_name|
          if instance_variable_name.to_sym == variable_name ||
              instance_variable_name.to_sym == "@#{variable_name}".to_sym
            found_name = instance_variable_name
            true
          end
        end

        found_name
      end

      def export_field_record(export_field, parent_object, parent_object_name, report_table, level, options = {})
        parent_expanded = options.delete(:expanded_field)
        report_object   = nil

        if (options.delete(:report_object_set))
          report_object = parent_object
        else
          if parent_object.respond_to?(export_field[:report_element][level]) &&
              (!parent_object.methods.include?(export_field[:report_element][level]) ||
                  parent_object.method(export_field[:report_element][level]).parameters.empty?)
            report_object = parent_object.send(export_field[:report_element][level])
          elsif parent_object.respond_to?(:[])
            key_value = export_field[:report_element][level]
            if key_value.to_s =~ /^-?[0-9]+$/
              key_value = key_value.to_s.to_i
            end

            report_object = parent_object.send(:[], key_value)
          else
            instance_variable_name = instance_variables_contain(parent_object, export_field[:report_element][level])

            if instance_variable_name
              report_object = parent_object.instance_variable_get(instance_variable_name)
            else
              report_object = nil
              print_value   = "Could not identify field: #{export_field[:report_element][0..level].join("__")} while exporting #{export_field[:report_element].join("__")}"

              report_table.write_stats "ERROR", print_value
            end
          end
        end

        if (level == 0 || !report_object.nil?) &&
            (level > 0 || export_field[:report_element][level] == parent_object_name)
          if level < export_field[:report_element].length - 1
            export_field_record(export_field,
                                report_object,
                                export_field[:report_element][level],
                                report_table,
                                level + 1,
                                options)
          else
            case export_field[:report_element][level]
              when :logs
                if Cornucopia::Util::Configuration.grab_logs
                  Cornucopia::Util::LogCapture.capture_logs report_table
                end

              when :capybara_page_diagnostics
                Cornucopia::Capybara::PageDiagnostics.dump_details_in_table(@report, report_table)

              else
                suppress = exclude_variable?(export_field[:report_element][0..-2], export_field[:report_element][-1])
                suppress &&= parent_expanded

                if !suppress &&
                    expand_variable?(export_field[:report_element][0..-2], export_field[:report_element][-1])
                  expand_field_object(export_field,
                                      report_object,
                                      export_field[:report_element][-1],
                                      report_table,
                                      level,
                                      options.merge({ expand_inline:
                                                          expand_variable_inline?(export_field[:report_element][0..-2],
                                                                                  export_field[:report_element][-1]) }))
                else
                  print_field_object(export_field, report_object, report_table, parent_expanded, options)
                end
            end
          end
        end
      end

      def print_field_object(export_field, report_object, report_table, parent_expanded, options)
        unless parent_expanded &&
            exclude_variable?(export_field[:report_element][0..-2], export_field[:report_element][-1])
          if report_object == false || !report_object.blank?
            if export_field[:report_element][-1] == :to_s
              print_name = export_field[:report_element][-2]
            else
              print_name = export_field[:report_element][-1]
            end

            if export_field[:report_element].length >= 2
              if print_name.to_s =~ /^-?[0-9]+$/
                if !parent_expanded ||
                    expand_variable_inline?(export_field[:report_element][0..-3], export_field[:report_element][-2])
                  print_name = "#{export_field[:report_element][-2]}[#{export_field[:report_element][-1]}]"
                end
              end
            end

            print_options = export_field[:report_options]
            print_options ||= find_leaf_options(print_name).try(:[], :report_options)
            print_options ||= {}

            if print_options[:label]
              print_name = print_options[:label]
            end

            report_table.write_stats print_name, report_object, print_options
          end
        end
      end

      def find_leaf_options(variable_name)
        found_options = nil

        if @leaf_options
          @leaf_options.each do |leaf_option|
            if leaf_option[:report_element].include?(variable_name)
              found_options = leaf_option
              break
            end
          end
        end

        found_options
      end

      def exclude_variable?(export_field, variable_name)
        find_variable_in_set(@exclude_fields, export_field, variable_name)
      end

      def expand_variable?(export_field, variable_name)
        find_variable_in_set(@expand_fields, export_field, variable_name) ||
            find_variable_in_set(@expand_inline_fields, export_field, variable_name)
      end

      def expand_variable_inline?(export_field, variable_name)
        find_variable_in_set(@expand_inline_fields, export_field, variable_name)
      end

      def find_variable_in_set(variable_set, export_field, variable_name)
        found_item = nil

        if variable_set
          variable_set.any? do |exclusion_item|
            found_item = nil

            if exclusion_item[:report_element].length == export_field.length + 1
              found_item = true

              export_field.each_with_index do |export_name, export_index|
                found_item &&= (exclusion_item[:report_element][export_index] == export_name ||
                    exclusion_item[:report_element][export_index] == "*".to_sym)
              end

              found_item &&= (exclusion_item[:report_element][export_field.length] == variable_name ||
                  exclusion_item[:report_element][export_field.length] == "*".to_sym)

              if found_item
                found_item = exclusion_item
              else
                found_item = nil
              end
            end

            found_item
          end
        end

        found_item
      end

      def split_field_symbols(full_report_element)
        if full_report_element
          full_report_element.map do |full_symbol|
            return_value = {}

            if full_symbol.is_a?(Hash)
              return_value                  = full_symbol.clone
              return_value[:report_element] = split_full_field_symbol(return_value[:report_element])
            else
              return_value[:report_element] = split_full_field_symbol(full_symbol)
            end

            return_value
          end
        else
          []
        end
      end

      def split_full_field_symbol(full_symbol)
        if full_symbol.is_a?(Array)
          full_symbol
        else
          field_symbols = full_symbol.to_s.split("__")

          field_symbols.reduce([]) do |array, symbol|
            if (symbol.empty?)
              array << nil
            else
              while (array.length > 0 && array[-1].blank?)
                array.pop
                symbol = "__#{symbol}"
              end
              array << symbol.to_sym
            end
          end
        end
      end

      def get_instance_variable(the_object, instance_variable, variable_name)
        if the_object.respond_to?(variable_name)
          the_object.send(variable_name)
        else
          the_object.instance_variable_get(instance_variable)
        end
      end
    end
  end
end