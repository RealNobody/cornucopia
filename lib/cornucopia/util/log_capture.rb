# require ::File.expand_path('configuration', File.dirname(__FILE__))
require ::File.expand_path('report_builder', File.dirname(__FILE__))

module Cornucopia
  module Util
    class LogCapture
      class << self
        TAIL_BUF_LENGTH = 1 << 16

        def backup_log_files(backup_folder)
          if Object.const_defined?("Rails")
            log_folder = Rails.root.to_s
            if (log_folder =~ /\/features\/?$/ || log_folder =~ /\/spec\/?$/)
              log_folder = File.join(log_folder, "../")
            end

            default_log_file = "log/#{Rails.env.to_s}.log"

            copy_log_file backup_folder, File.join(log_folder, default_log_file)
          else
            log_folder = FileUtils.pwd
          end

          Cornucopia::Util::Configuration.user_log_files.each do |relative_log_file, options|
            copy_log_file backup_folder, File.join(log_folder, relative_log_file)
          end
        end

        def copy_log_file(dest_folder, source_file)
          extension = File.extname(source_file)
          file_name = File.basename(source_file, extension)
          dest_name = File.join(dest_folder, "#{file_name}#{extension}")
          index     = 0

          while File.exist?(dest_name)
            index     += 1
            dest_name = File.join(dest_folder, "#{file_name}_#{index}#{extension}")
          end

          if File.exist?(source_file)
            FileUtils.mkdir_p File.dirname(dest_name)
            FileUtils.cp source_file, dest_name
          end
        end

        # This function will capture the logs and output them to the report
        def capture_logs(report_table)
          if report_table
            if Object.const_defined?("Rails")
              log_folder = Rails.root.to_s
              if (log_folder =~ /\/features\/?$/ || log_folder =~ /\/spec\/?$/)
                log_folder = File.join(log_folder, "../")
              end

              default_log_file = "log/#{Rails.env.to_s}.log"

              output_log_file(report_table, File.join(log_folder, default_log_file))
            else
              log_folder = FileUtils.pwd
            end

            Cornucopia::Util::Configuration.user_log_files.each do |relative_log_file, options|
              output_log_file(report_table, File.join(log_folder, relative_log_file), options)
            end
          else
            Cornucopia::Util::ReportBuilder.current_report.within_section("Log Dump:") do |report|
              report.within_table do |new_report_table|
                Cornucopia::Util::LogCapture.capture_logs new_report_table
              end
            end
          end
        end

        def highlight_log_output(log_text)
          output_text = Cornucopia::Util::ReportBuilder.format_code_refs(log_text)
          output_text = output_text.gsub(/^(Completed [^23].*)$/, "<span class=\"completed-error\">\\1<\/span>")
          output_text = output_text.gsub(/^(Completed [23].*)$/, "<span class=\"completed-other\">\\1<\/span>")

          output_text.html_safe
        end

        # A cheap and sleazy tail function, but it should work...
        def output_log_file(report_table, log_file_name, options = {})
          if File.exist?(log_file_name)
            output_file = false

            options.reverse_merge!({ num_lines: Cornucopia::Util::Configuration.num_lines })

            num_lines  = options[:num_lines] || Cornucopia::Util::Configuration.num_lines
            num_lines  = Cornucopia::Util::Configuration.num_lines if num_lines <= 0
            log_buffer = ""
            file_size  = File.size(log_file_name)

            File.open(log_file_name) do |log_file|
              seek_len = [file_size, TAIL_BUF_LENGTH].min
              log_file.seek(-seek_len, IO::SEEK_END)

              while (log_buffer.count("\n") <= num_lines)
                log_buffer = log_file.read(seek_len) + log_buffer

                file_size -= seek_len
                seek_len  = [file_size, TAIL_BUF_LENGTH].min

                break if seek_len <= 0

                log_file.seek(-seek_len - TAIL_BUF_LENGTH, IO::SEEK_CUR)
              end
            end

            if log_buffer
              log_buffer = log_buffer.split("\n")
              if (log_buffer.length > num_lines)
                log_buffer = log_buffer[-num_lines..-1]
              end

              report_table.write_stats File.basename(log_file_name),
                                       Cornucopia::Util::PrettyFormatter.format_string(
                                           Cornucopia::Util::LogCapture.highlight_log_output(
                                               "log_file - #{log_file_name}:#{file_size}\n#{log_buffer.join("\n")}"
                                           )
                                       ),
                                       do_not_pretty_print: true

              output_file = true
            end

            output_file
          end
        end
      end
    end
  end
end