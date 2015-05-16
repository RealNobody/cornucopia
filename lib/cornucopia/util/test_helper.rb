require "singleton"

module Cornucopia
  module Util
    class TestHelper
      include Singleton

      attr_accessor :spinach_reported_error, :spinach_running_scenario

      def cucumber_name(scenario)
        report_name = "Unknown"
        if scenario.respond_to?(:feature)
          report_name = "#{scenario.feature.title}:#{scenario.title}"
        elsif scenario.respond_to?(:line)
          report_name = "Line - #{scenario.line}"
        end

        report_name
      end

      def spinach_name(scenario_data)
        "#{scenario_data.feature.name} : #{scenario_data.name}"
      end

      def rspec_name(example)
        example.full_description
      end

      def record_test_start(test_name)
        record_test("Start", test_name)
      end

      def record_test_end(test_name)
        record_test("End", test_name)
      end

      def test_message(start_end, test_name)
        Cornucopia::Util::Configuration.record_test_start_and_end_format % {
            start_end: start_end,
            test_name: test_name
        }
      end

      def record_test(start_end, test_name)
        if Cornucopia::Util::Configuration.record_test_start_and_end_in_log
          if Object.const_defined?("Rails")
            Rails.logger.error(test_message(start_end, test_name))
          end
        end
      end
    end
  end
end