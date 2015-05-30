require "singleton"
require ::File.expand_path('configured_report', File.dirname(__FILE__))
require ::File.expand_path('generic_settings', File.dirname(__FILE__))
require ::File.expand_path('report_formatters', File.dirname(__FILE__))

module Cornucopia
  module Util
    class Configuration
      include Singleton

      attr_accessor :configurations

      def initialize
        @configurations = Cornucopia::Util::GenericSettings.new

        configurations.order_seed                       = nil
        configurations.rand_seed                        = nil
        configurations.rand_context_seed                = nil
        configurations.user_log_files                   = {}
        configurations.default_num_lines                = 500
        configurations.grab_logs                        = true
        configurations.backup_logs_on_failure           = true
        configurations.print_timeout_min                = 10
        configurations.selenium_cache_retry_count       = 5
        configurations.analyze_find_exceptions          = true
        configurations.analyze_selector_exceptions      = true
        configurations.ignore_finder_errors_on_success  = true
        configurations.ignore_has_selector_errors       = true
        configurations.record_test_start_and_end_in_log = true
        configurations.record_test_start_and_end_format = "******** %{start_end}: %{test_name}"
        configurations.retry_with_found                 = false
        configurations.retry_match_with_found           = false
        configurations.open_report_settings             = { default: false }
        configurations.base_folder                      = "cornucopia_report"
        configurations.benchmark                        = false

        # configurations.alternate_retry            = false

        configurations.default_configuration            = {
            rspec:                       {
                min_fields:           [
                                          :example__full_description,
                                          :example__location,
                                          :example__exception__to_s,
                                          :example__exception__backtrace
                                      ],
                more_info_fields:     [
                                          :example__exception__class__name,
                                          :example,
                                          :example__example_group_instance,
                                          :example__metadata__caller,
                                          {
                                              report_element: :rspec__configuration__seed,
                                              report_options: { ignore_missing: true }
                                          },
                                          {
                                              report_element: :rspec__configuration__ordering_manager__seed,
                                              report_options: { ignore_missing: true }
                                          },
                                          :logs,
                                          :capybara_page_diagnostics
                                      ],
                expand_fields:        [
                                          :example,
                                          :example__example_group_instance__response,
                                          :example__example_group_instance__controller,
                                          :example__example_group_instance__request,
                                          :example__example_group_instance
                                      ],
                expand_inline_fields: [
                                          :example__example_group_instance____memoized
                                      ],
                exclude_fields:       [
                                          :example__fixture_connections,
                                          :example,
                                          :example__example_group_instance,
                                      ],
            },
            cucumber:                    {
                min_fields:           [
                                          {
                                              report_element: :scenario__feature__title,
                                              report_options: { label: "feature" }
                                          },
                                          {
                                              report_element: :scenario__feature__location,
                                              # report_options: { format: ->(value) { "#{value.file}:#{value.line}" } }
                                              report_options: { format_object:   Cornucopia::Util::CucumberFormatter,
                                                                format_function: :format_location }
                                          },
                                          {
                                              report_element: :scenario__title,
                                              report_options: { label: "scenario" }
                                          },
                                          {
                                              report_element: :scenario__location,
                                              report_options: { format_object:   Cornucopia::Util::CucumberFormatter,
                                                                format_function: :format_location }
                                          },
                                          :scenario__exception__to_s,
                                          :scenario__exception__backtrace
                                      ],
                more_info_fields:     [
                                          :scenario__exception__class__name,
                                          :scenario,
                                          :scenario__feature__comment,
                                          :scenario__feature__keyword,
                                          :scenario__feature__description,
                                          :scenario__feature__gherkin_statement,
                                          :scenario__feature__tags,
                                          :scenario__current_visitor__configuration,
                                          :cucumber,
                                          :logs,
                                          :capybara_page_diagnostics
                                      ],
                expand_fields:        [
                                          :scenario,
                                          :cucumber,
                                      ],
                expand_inline_fields: [
                                      ],
                exclude_fields:       [
                                          :scenario__background,
                                          :scenario__feature,
                                          :scenario__current_visitor,
                                          :scenario__raw_steps,
                                          :scenario__title,
                                          :scenario__location,
                                          :cucumber____cucumber_runtime,
                                          :cucumber____natural_language,
                                          :cucumber___rack_test_sessions,
                                          :cucumber___rack_mock_sessions,
                                          :cucumber__integration_session
                                      ]
            },
            cucumber_outline:            {
                min_fields:           [
                                          {
                                              report_element: :scenario__scenario_outline__name,
                                              report_options: { label: "feature_outline" }
                                          },
                                          {
                                              report_element: :scenario__name,
                                              report_options: { label: "scenario_example" }
                                          },
                                          {
                                              report_element: :scenario__scenario_outline__example_sections__0__0__0,
                                              # report_options: { format: ->(value) { "#{value.file}:#{value.line}" } }
                                              report_options: { format_object:   Cornucopia::Util::CucumberFormatter,
                                                                format_function: :format_location }
                                          },
                                          :scenario__exception__to_s,
                                          :scenario__exception__backtrace
                                      ],
                more_info_fields:     [
                                          :scenario__exception__class__name,
                                          :scenario,
                                          :scenario__scenario_outline__example_sections__0__1__comments,
                                          :scenario__scenario_outline__example_sections__0__1__keyword,
                                          :scenario__scenario_outline__example_sections__0__1__description,
                                          :scenario__source_tag_names,
                                          :scenario__scenario_outline__example_sections__0__1__tags,
                                          :scenario__scenario_outline__example_sections__0__0,
                                          :scenario__scenario_outline,
                                          :cucumber,
                                          :logs,
                                          :capybara_page_diagnostics
                                      ],
                expand_fields:        [
                                          :scenario,
                                          :scenario__scenario_outline,
                                          :cucumber,
                                      ],
                expand_inline_fields: [
                                      ],
                exclude_fields:       [
                                          :scenario__background,
                                          :scenario__scenario_outline__background,
                                          :scenario__table,
                                          :scenario__feature,
                                          :scenario__current_visitor,
                                          :scenario__raw_steps,
                                          :scenario__title,
                                          :cucumber____cucumber_runtime,
                                          :cucumber____natural_language,
                                          :cucumber___rack_test_sessions,
                                          :cucumber___rack_mock_sessions,
                                          :cucumber__integration_session
                                      ]
            },
            spinach:                     {
                min_fields:           [
                                          :failure_description,
                                          :running_scenario__feature__name,
                                          :running_scenario__name,
                                          :running_scenario__line,
                                          :step_data__name,
                                          :step_data__line,
                                          :exception__to_s,
                                          :exception__backtrace
                                      ],
                more_info_fields:     [
                                          :exception__class__name,
                                          :running_scenario__feature__tags,
                                          :running_scenario,
                                          :step_data,
                                          :step_definitions,
                                          :logs,
                                          :capybara_page_diagnostics
                                      ],
                expand_fields:        [
                                          :running_scenario,
                                          :step_data,
                                          :step_definitions
                                      ],
                expand_inline_fields: [
                                      ],
                exclude_fields:       [
                                          :running_scenario__feature,
                                          :step_data__scenario__feature,
                                          :running_scenario__name,
                                          :running_scenario__line,
                                          :step_data__name,
                                          :step_data__line
                                      ]
            },
            capybara_page_diagnostics:   {
                min_fields:           [
                                          :capybara__page_url,
                                          :capybara__title,
                                          :capybara__screen_shot
                                      ],
                more_info_fields:     [
                                          :capybara,
                                          :capybara__other_windows,
                                      ],
                expand_fields:        [
                                          :capybara,
                                          :capybara__other_windows,
                                          "capybara__other_windows__*",
                                      ],
                expand_inline_fields: [
                                          :capybara,
                                      ],
                exclude_fields:       [
                                          :capybara__page_url,
                                          :capybara__title,
                                          :capybara__screen_shot,
                                          :capybara__page_url,
                                          :capybara__title,
                                          :capybara__screen_shot,
                                          :capybara__options,
                                          :capybara__report,
                                          :capybara__table,
                                          :capybara__unsupported_list,
                                          :capybara__allow_other_windows,
                                          :capybara__iterating,
                                          :capybara__session,
                                          :capybara__driver,
                                          :capybara__window_handles,
                                          :capybara__current_window,
                                          "capybara__other_windows__*__options",
                                          "capybara__other_windows__*__report",
                                          "capybara__other_windows__*__table",
                                          "capybara__other_windows__*__unsupported_list",
                                          "capybara__other_windows__*__allow_other_windows",
                                          "capybara__other_windows__*__iterating",
                                          "capybara__other_windows__*__session",
                                          "capybara__other_windows__*__driver",
                                          "capybara__other_windows__*__window_handles",
                                          "capybara__other_windows__*__current_window"
                                      ],
                leaf_options:         [
                                          { report_element: [:html_source,
                                                             :html_frame,
                                                             :screen_shot
                                                            ],
                                            report_options: { prevent_shrink:      true,
                                                              exclude_code_block:  true,
                                                              do_not_pretty_print: true
                                            }
                                          },
                                          { report_element: [:html_file],
                                            report_options: { exclude_code_block: true },
                                          }
                                      ]
            },
            capybara_finder_diagnostics: {
                min_fields:           [
                                          :finder__function_name,
                                          :finder__args__0,
                                          :finder__search_args,
                                          :finder__options,
                                          :exception__to_s,
                                          :exception__backtrace
                                      ],
                more_info_fields:     [
                                          :exception__class__name,
                                          :finder,
                                          :capybara_page_diagnostics
                                      ],
                expand_fields:        [
                                          :finder,
                                          :finder__args,
                                          :finder__all_elements,
                                          :finder__all_other_elements,
                                          "finder__all_elements__*",
                                          "finder__all_other_elements__*",
                                          "finder__all_elements__*__native_size",
                                          "finder__all_other_elements__*__native_size",
                                          "finder__all_elements__*__elem_location",
                                          "finder__all_other_elements__*__elem_location",
                                          :finder__search_args,
                                          :finder__options
                                      ],
                expand_inline_fields: [
                                          :finder
                                      ],
                exclude_fields:       [
                                          :finder__return_value,
                                          :finder__function_name,
                                          :finder__args__0,
                                          :finder__search_args,
                                          :finder__options,
                                          :finder__report_options,
                                          :finder__test_object,
                                          "finder__all_elements__*__found_element",
                                          "finder__all_other_elements__*__found_element"
                                      ]
            }
        }

        configurations.configured_reports = {}
      end

      class << self
        # rand_seed is the seed value used to seed the srand function at the start of a test
        # suite.  This is done to allow tests with random elements in them to be repeatable.
        # If a test fails, simply set Cornucopia::Util::Configuration.rand_seed to the
        # value of the failed tests seed value (output in the stdout and the generated report)
        # and run the test again.  This should re-run the exact same test, resulting in a
        # repeatable test even with randomization in it.
        def seed=(value)
          Cornucopia::Util::Configuration.instance.configurations.rand_seed = value
          srand(value) if value
        end

        def seed
          Cornucopia::Util::Configuration.instance.configurations.rand_seed
        end

        # rand_context_seed is the seed value used to seed the srand function at the start of a context.
        # This is done to allow tests with random elements in them to be repeatable.
        # If a test fails, simply set Cornucopia::Util::Configuration.rand_context_seed to the
        # value of the failed tests context_seed value (output in the stdout and the generated report)
        # and run the test again.  This should re-run the exact same test, resulting in a
        # repeatable test even with randomization in it.
        def context_seed=(value)
          Cornucopia::Util::Configuration.instance.configurations.rand_context_seed = value
          srand(value) if value
        end

        def context_seed
          Cornucopia::Util::Configuration.instance.configurations.rand_context_seed
        end

        # order_seed is the seed value used to set the order that randomly ordered tests are run in.
        # This is provided as a convenience method.  I think it is easier to set this in rails_helper than it is to
        # set it on the command line.  This also provides a uniform method to do it.
        def order_seed=(value)
          Cornucopia::Util::Configuration.instance.configurations.order_seed = value

          if value
            if RSpec.configuration.respond_to?(:seed)
              RSpec.configuration.seed = value
            else
              # :nocov:
              RSpec.configuration.ordering_manager.seed = value
              # :nocov:
            end
          end
        end

        def order_seed
          Cornucopia::Util::Configuration.instance.configurations.order_seed
        end

        # grab_logs indicates if the system should try to automatically grab a tail of
        # the log file if outputing a diagnostics report.
        #
        # The system will try to grab the following log files:
        #   * Rails.env.log
        #   * any user specified logs
        #
        # The log capture is done by reading from the end of the file
        # of the log file.  If the log file cannot be found, or if the system
        # cannot open the file (no access rights, etc.) nothing will be output.
        #
        # Related options:
        #   user_log_files
        #   num_lines
        #   add_log_file
        #   remove_log_file
        def grab_logs=(value)
          Cornucopia::Util::Configuration.instance.configurations.grab_logs = value
        end

        def grab_logs
          Cornucopia::Util::Configuration.instance.configurations.grab_logs
        end

        # backup_logs_on_failure causes the system to copy the log files at the end of the report cycle if there were
        # any errors during the creation of the report system.
        #
        # The system will try to grab the following log files:
        #   * Rails.env.log
        #   * any user specified logs
        #
        # The log capture is done with a simple file copy.
        #
        # Related options:
        #   user_log_files
        #   num_lines
        #   add_log_file
        #   remove_log_file
        #   grab_logs
        def backup_logs_on_failure=(value)
          Cornucopia::Util::Configuration.instance.configurations.backup_logs_on_failure = value
        end

        def backup_logs_on_failure
          Cornucopia::Util::Configuration.instance.configurations.backup_logs_on_failure
        end

        # user_log_files returns a hash of all of the log files which
        # the user has specified are to be grabbed.
        #
        # The keys are the relative paths of the log files to be
        # grabbed, and the values are the options specified for the
        # files.  The values may be an empty hash.
        def user_log_files
          Cornucopia::Util::Configuration.instance.configurations.user_log_files.clone
        end

        # num_lines returns the number of lines that will be grabbed
        # for a file.  If no file name is supplied, or the name does not match a
        # user file, the default log length will returned.
        def num_lines(log_file_name=nil)
          Cornucopia::Util::Configuration.instance.configurations.user_log_files[log_file_name].try(:[], :num_lines) ||
              Cornucopia::Util::Configuration.instance.configurations.default_num_lines
        end

        # default_num_lines sets the default number of lines to extract from the log file
        def default_num_lines=(value)
          Cornucopia::Util::Configuration.instance.configurations.default_num_lines = value
        end

        # Adds the specified log file to the list of log files to capture.
        # If the log file is already in the list, the passed in options will be merged with
        # the existing options.
        # See Cornucopia::LogCapture
        def add_log_file(log_file_name, options = {})
          Cornucopia::Util::Configuration.instance.configurations.user_log_files[log_file_name] ||= {}
          Cornucopia::Util::Configuration.instance.configurations.user_log_files[log_file_name] =
              Cornucopia::Util::Configuration.instance.configurations.user_log_files[log_file_name].merge options
        end

        # Removes the specified log file from the list of log files to capture.
        # NOTE:  You cannot remove the default log file.
        def remove_log_file(log_file_name)
          Cornucopia::Util::Configuration.instance.configurations.user_log_files.delete log_file_name
        end

        # returns the report configuration object for that type of report
        #
        # values for report_name:
        #   :rspec
        #   :cucumber
        #   :spinach
        #   :capybara_page_diagnostics
        def report_configuration(report_name)
          Cornucopia::Util::Configuration.instance.configurations.configured_reports[report_name] ||=
              Cornucopia::Util::ConfiguredReport.new(Cornucopia::Util::Configuration.instance.configurations.default_configuration[report_name])
        end

        # sets the report configuration object for that type of report from a configuration has that is passed in
        #
        # values for report_name:
        #   :rspec
        #   :cucumber
        #   :spinach
        #   :capybara_page_diagnostics
        def set_report_configuration(report_name, configuration)
          if configuration.is_a?(Cornucopia::Util::ConfiguredReport)
            Cornucopia::Util::Configuration.instance.configurations.configured_reports[report_name] = configuration
          else
            Cornucopia::Util::Configuration.instance.configurations.configured_reports[report_name] =
                Cornucopia::Util::ConfiguredReport.new(configuration)
          end
        end

        # returns the report configuration object for that type of report
        #
        # values for report_name:
        #   :rspec
        #   :cucumber
        #   :spinach
        #   :capybara_page_diagnostics
        def default_report_configuration(report_name)
          Cornucopia::Util::Configuration.instance.configurations.default_configuration[report_name].try :clone
        end

        # Sets or returns the minimum amount of time in seconds to allow for the printing of variables.
        # If it is available, the larger of this value and Capybara.default_wait_time will be used.
        #
        # This value exists to prevent the printing of a value on a report from taking too long
        # and holding up the system.  If it takes longer than this amount of time to get the value
        # it probably isn't diagnostically important.
        #
        # Default: 10
        def print_timeout_min
          Cornucopia::Util::Configuration.instance.configurations.print_timeout_min
        end

        def print_timeout_min=(value)
          Cornucopia::Util::Configuration.instance.configurations.print_timeout_min = value
        end

        # The Selenium driver can throw a StaleElementReferenceError exception sometimes.
        # I often see it with animated items like dialog boxes and the like.  When the system
        # is looping trying to find the element or stop seeing it.
        #
        # Because the element likely just disappeared between when it was found and when it
        # was returned, trying again will often make the problem go away.
        #
        # The default for this setting is 5 which will retry the find function if this error
        # occurs.
        #
        # NOTE:  This should already be the default action (basically) for the Selenium
        #        driver, yet from a purely practical standpoint, this seems to be a problem
        #        that I've run into a lot.  I am doing it this way to see if I can reduce the
        #        the occurrence of it.
        def selenium_cache_retry_count
          Cornucopia::Util::Configuration.instance.configurations.selenium_cache_retry_count
        end

        def selenium_cache_retry_count=(value)
          Cornucopia::Util::Configuration.instance.configurations.selenium_cache_retry_count = value
        end

        # This setting is used by the Capybara utilities.
        #
        # When Capybara::Node.find throws an exception, if this is set, the system will try to
        # use the FinderDiagnostics to output some diagnostic information about the page and the finder
        # to try to assist in determining what happened.
        def analyze_find_exceptions
          Cornucopia::Util::Configuration.instance.configurations.analyze_find_exceptions
        end

        def analyze_find_exceptions=(value)
          Cornucopia::Util::Configuration.instance.configurations.analyze_find_exceptions = value
        end

        # This setting is used by the Capybara utilities.
        #
        # When Capybara::Node.analyze_selector throws an exception, if this is set, the system will try to
        # use the FinderDiagnostics to output some diagnostic information about the page and the
        # selector to try to assist in determining what happened.
        def analyze_selector_exceptions
          Cornucopia::Util::Configuration.instance.configurations.analyze_selector_exceptions
        end

        def analyze_selector_exceptions=(value)
          Cornucopia::Util::Configuration.instance.configurations.analyze_selector_exceptions = value
        end

        # This setting is used by the report builder.
        #
        # If a test has finder errors but still succeeds, ignore the errors and do not report them.  This is useful
        # for tests that test the existence of an element on the page using something like:
        # expect(my_page).not_to have_page_element
        def ignore_finder_errors_on_success
          Cornucopia::Util::Configuration.instance.configurations.ignore_finder_errors_on_success
        end

        def ignore_finder_errors_on_success=(value)
          Cornucopia::Util::Configuration.instance.configurations.ignore_finder_errors_on_success = value
        end

        # This setting is used by the matcher analysis.
        #
        # Generally speaking has_selector? is allowed to return true or false without needing to be to analyzed.
        # So, the system ignores has_selector? failures and doesn't output an analysis.
        #
        # This will perform an analysis for each has_selector? failure.
        def ignore_has_selector_errors
          Cornucopia::Util::Configuration.instance.configurations.ignore_has_selector_errors
        end

        def ignore_has_selector_errors=(value)
          Cornucopia::Util::Configuration.instance.configurations.ignore_has_selector_errors = value
        end

        # Sometimes, the analysis process found the element when it wasn't found other ways.
        # This will cause the finder to try again with the found element.
        #
        # The default is false because I haven't seen this be useful in a while.
        #
        # WARNING:  Using this is unsafe.  If you use it, you could get false positive
        #           results in your test.
        def retry_with_found
          Cornucopia::Util::Configuration.instance.configurations.retry_with_found
        end

        def retry_with_found=(value)
          Cornucopia::Util::Configuration.instance.configurations.retry_with_found = value
        end

        # Sometimes, the analysis process found the element when it wasn't found other ways.
        # This will cause the match accessor to try again with the found element.
        #
        # The default is true because I have been getting a fair number of false negatives.
        def retry_match_with_found
          Cornucopia::Util::Configuration.instance.configurations.retry_match_with_found
        end

        def retry_match_with_found=(value)
          Cornucopia::Util::Configuration.instance.configurations.retry_match_with_found = value
        end

        # To make it easier to know about and to see the reports, this configuration will cause a report to be
        # automatically opened if there is anything to report when the report is closed.
        #
        # The posible values for report_name are:
        #   nil
        #   "rspec_report"
        #   "cucumber_report"
        #   "spinach_report"

        def auto_open_report_after_generation(open_report, report_name = nil)
          Cornucopia::Util::Configuration.instance.configurations.open_report_settings[report_name || :default] = open_report
        end

        def open_report_after_generation(report_name)
          open_report = Cornucopia::Util::Configuration.instance.configurations.open_report_settings[report_name]
          open_report = Cornucopia::Util::Configuration.instance.configurations.open_report_settings[:default] if open_report.nil?
          open_report
        end

        ### Commented this out.
        ### When I originally found a need for this type of function, I needed this feature.
        ### Since then, I haven't.  I don't think this is needed anymore, so I'm leaving it out
        ### in this re-write for now.  I'll add it back if I feel it is needed.

        # # I have actually found times when the Selenium driver (in particular) simply would not work.
        # # It was a bug.  I think I've upgraded a couple of times since then and the problem probably
        # # went away.  It is useful code anyway, so I'm keeping it.
        # #
        # # In the event that default code simply won't work, this is a hail mary option which tries
        # # to do whatever you were trying to do directly through javascript.
        # #
        # # This will only work if the element you are trying to manipulate (get the text or value from,
        # # click, etc.) has an ID.
        # #
        # # The default is false since it is unlikely to work in so many circumstances
        # #
        # # WARNING:  Using this is unsafe.  If you use it, you could get false positive
        # #           results in your test.
        # def alternate_retry
        #   Cornucopia::Util::Configuration.instance.configurations.alternate_retry
        # end
        #
        # def alternate_retry=(value)
        #   Cornucopia::Util::Configuration.instance.configurations.alternate_retry = value
        # end

        # Sets or returns the name of the folder to generate reports into.
        #
        # Default: "cornucopia_report"
        def base_folder
          Cornucopia::Util::Configuration.instance.configurations.base_folder
        end

        def base_folder=(value)
          Cornucopia::Util::Configuration.instance.configurations.base_folder = value
        end

        # This setting is used by the test system hooks.
        #
        # If true (the default) this will cause the system to output a line to the Rails log indicating when a test
        # starts and when it ends.
        def record_test_start_and_end_in_log
          Cornucopia::Util::Configuration.instance.configurations.record_test_start_and_end_in_log
        end

        def record_test_start_and_end_in_log=(value)
          Cornucopia::Util::Configuration.instance.configurations.record_test_start_and_end_in_log = value
        end

        # This setting is used by the test system hooks.
        #
        # This value specifies the text that is output into the log file at the start/end of a test.
        # Two variables are passed into the format string to be inserted into the text:
        #
        #   * %{start_end} - This will be either "Start" or "End"
        #   * %{test_name} - This will the the name of the test.
        def record_test_start_and_end_format
          Cornucopia::Util::Configuration.instance.configurations.record_test_start_and_end_format
        end

        def record_test_start_and_end_format=(value)
          Cornucopia::Util::Configuration.instance.configurations.record_test_start_and_end_format = value
        end

        # Turns benchmarking on or off.
        #
        # Defaults to false.
        def benchmark
          Cornucopia::Util::Configuration.instance.configurations.benchmark
        end

        def benchmark=(value)
          Cornucopia::Util::Configuration.instance.configurations.benchmark = value
        end
      end
    end
  end
end