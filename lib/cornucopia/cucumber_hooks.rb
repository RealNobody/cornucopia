require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

require "singleton"

class CucumberHookStatus
  include Singleton

  attr_accessor :failed_scenario
end

if Cucumber::VERSION.split[0].to_i >= 2
  After do |scenario, block|
    time = Benchmark.measure do
      puts "Cornucopia::Hook::page dump" if Cornucopia::Util::Configuration.benchmark

      if scenario.failed?
        CucumberHookStatus.instance.failed_scenario = scenario

        report_name = "Page Dump for: #{Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)}"

        Cornucopia::Capybara::PageDiagnostics.dump_details(section_label: report_name)
      end
    end

    puts "Cornucopia::Hook::page dump time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end

  Around do |scenario_proxy, block|
    test_name = nil

    scenario = scenario_proxy
    time = Benchmark.measure do
      puts "Cornucopia::Hook::before test" if Cornucopia::Util::Configuration.benchmark

      test_name = Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)
      Cornucopia::Util::TestHelper.instance.record_test_start(test_name)

      seed_value = Cornucopia::Util::Configuration.seed ||
          100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

      scenario.instance_variable_set :@seed_value, seed_value

      Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
      Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages
    end

    puts "Cornucopia::Hook::before test time: #{time}" if Cornucopia::Util::Configuration.benchmark

    Cornucopia::Util::ReportBuilder.current_report.within_test("Scenario - #{test_name}") do
      CucumberHookStatus.instance.failed_scenario = nil

      block.call

      time = Benchmark.measure do
        puts "Cornucopia::Hook::after test" if Cornucopia::Util::Configuration.benchmark

        if scenario.failed? || CucumberHookStatus.instance.failed_scenario
          seed_value = scenario.instance_variable_get(:@seed_value)
          puts ("random seed for testing was: #{seed_value}")

          if CucumberHookStatus.instance.failed_scenario && !scenario.failed?
            # In 2.0, the scenario in the around block is actually a scenario_proxy.  This means that it isn't the real
            # scenario that failed.  Therefore sometimes it doesn't have the real value of failed? or exception.
            # For this reason, I capture the "real" scenario in the after hook if it fails and use it here.
            scenario = CucumberHookStatus.instance.failed_scenario
            scenario.instance_variable_set(:@seed_value, seed_value)
          end

          Cornucopia::Util::ReportBuilder.current_report.within_section("Test Error: #{test_name}") do |report|
            configured_report = nil
            if scenario.respond_to?(:feature)
              configured_report = Cornucopia::Util::Configuration.report_configuration :cucumber
            else
              configured_report = Cornucopia::Util::Configuration.report_configuration :cucumber_outline
            end

            configured_report.add_report_objects scenario: scenario, cucumber: self
            configured_report.generate_report(report)
          end
        else
          Cornucopia::Util::ReportBuilder.current_report.test_succeeded
        end

        Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
        Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

        Cornucopia::Util::TestHelper.instance.record_test_end(test_name)
      end
    end

    puts "Cornucopia::Hook::after test time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end
else
  Before do |scenario, block|
    time = Benchmark.measure do
      puts "Cornucopia::Hook::before test" if Cornucopia::Util::Configuration.benchmark

      test_name = Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)
      Cornucopia::Util::TestHelper.instance.record_test_start(test_name)

      seed_value = Cornucopia::Util::Configuration.seed ||
          100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

      scenario.instance_variable_set :@seed_value, seed_value

      Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
      Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

      Cornucopia::Util::ReportBuilder.current_report.start_test(scenario, "Scenario - #{test_name}")
    end

    puts "Cornucopia::Hook::before test time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end

  After do |scenario, block|
    time = Benchmark.measure do
      puts "Cornucopia::Hook::after test" if Cornucopia::Util::Configuration.benchmark

      test_name = Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)

      if scenario.failed?
        seed_value = scenario.instance_variable_get(:@seed_value)
        puts ("random seed for testing was: #{seed_value}")

        Cornucopia::Util::ReportBuilder.current_report.within_section("Test Error: #{test_name}") do |report|
          configured_report = nil
          if scenario.respond_to?(:feature)
            configured_report = Cornucopia::Util::Configuration.report_configuration :cucumber
          else
            configured_report = Cornucopia::Util::Configuration.report_configuration :cucumber_outline
          end

          configured_report.add_report_objects scenario: scenario, cucumber: self
          configured_report.generate_report(report)
        end
      else
        Cornucopia::Util::ReportBuilder.current_report.test_succeeded
      end

      Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
      Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

      Cornucopia::Util::ReportBuilder.current_report.end_test(scenario)

      Cornucopia::Util::TestHelper.instance.record_test_end(test_name)
    end

    puts "Cornucopia::Hook::after test time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end
end

at_exit do
  time = Benchmark.measure do
    puts "Cornucopia::Hook::suite end" if Cornucopia::Util::Configuration.benchmark

    Cornucopia::Util::ReportBuilder.current_report.close
  end

  puts "Cornucopia::Hook::suite end time: #{time}" if Cornucopia::Util::Configuration.benchmark
end

time = Benchmark.measure do
  puts "Cornucopia::Hook::suite start" if Cornucopia::Util::Configuration.benchmark

  Cornucopia::Util::ReportBuilder.new_report("cucumber_report")
end

puts "Cornucopia::Hook::suite start time: #{time}" if Cornucopia::Util::Configuration.benchmark