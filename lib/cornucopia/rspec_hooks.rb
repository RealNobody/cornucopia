require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
require "singleton"

load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_matcher_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

module Cornucopia
  class RSpecHelper
    include Singleton

    attr_accessor :last_reported_example
    attr_accessor :context_seed_value
    attr_accessor :seed_value

    def initialize
      @last_reported_example = nil
    end

    def end_example(example)
      unless example == last_reported_example
        if (example.exception)
          @last_reported_example = example

          puts("random seed for testing was: #{context_seed_value}, #{seed_value}")

          Cornucopia::Util::ReportBuilder.current_report.
              within_section("Test Error: #{example.full_description}") do |report|
            configured_report = Cornucopia::Util::Configuration.report_configuration :rspec

            configured_report.add_report_objects example: example, rspec: RSpec, seeds: self
            configured_report.generate_report(report)
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.seed = Cornucopia::Util::Configuration.order_seed if Cornucopia::Util::Configuration.order_seed

  config.before(:suite) do |*args|
    time = Benchmark.measure do
      puts "Cornucopia::Hook::suite start" if Cornucopia::Util::Configuration.benchmark

      Cornucopia::Util::ReportBuilder.new_report("rspec_report")
    end

    puts "Cornucopia::Hook::suite start time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end

  config.after(:suite) do
    time = Benchmark.measure do
      puts "Cornucopia::Hook::suite end" if Cornucopia::Util::Configuration.benchmark

      Cornucopia::Util::ReportBuilder.current_report.close
    end

    puts "Cornucopia::Hook::suite end time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end

  config.before(:all) do
    time = Benchmark.measure do
      puts "Cornucopia::Hook::before group" if Cornucopia::Util::Configuration.benchmark

      Cornucopia::RSpecHelper.instance.context_seed_value = Cornucopia::Util::Configuration.context_seed ||
          100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

      srand(Cornucopia::RSpecHelper.instance.context_seed_value)
    end

    puts "Cornucopia::Hook::before group time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end

  # Capybara resets the page in an after or around block before the around diagnostics can get around to dumping it
  # so by adding an after block here, we can dump the Capybara results if there is a problem.
  config.after(:each) do |example|
    time = Benchmark.measure do
      puts "Cornucopia::Hook::page dump" if Cornucopia::Util::Configuration.benchmark

      test_example = example.example if example.respond_to?(:example)
      test_example ||= self.example if self.respond_to?(:example)
      test_example ||= example

      if (test_example.exception)
        Cornucopia::Capybara::PageDiagnostics.dump_details(section_label: "Page Dump for: #{test_example.full_description}")
      end

      Cornucopia::RSpecHelper.instance.end_example(test_example)
    end

    puts "Cornucopia::Hook::page dump time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end

  config.around(:each) do |example|
    test_example = nil

    time = Benchmark.measure do
      puts "Cornucopia::Hook::before test" if Cornucopia::Util::Configuration.benchmark

      test_example = example.example if example.respond_to?(:example)
      test_example ||= self.example if self.respond_to?(:example)
      test_example ||= example

      Cornucopia::Util::TestHelper.instance.record_test_start(test_example.full_description)

      Cornucopia::RSpecHelper.instance.seed_value = Cornucopia::Util::Configuration.seed ||
          100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

      srand(Cornucopia::RSpecHelper.instance.seed_value)

      Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
      Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages
    end

    puts "Cornucopia::Hook::before test time: #{time}" if Cornucopia::Util::Configuration.benchmark

    Cornucopia::Util::ReportBuilder.current_report.within_test(test_example.full_description) do
      example.run

      time = Benchmark.measure do
        puts "Cornucopia::Hook::after test" if Cornucopia::Util::Configuration.benchmark

        Cornucopia::RSpecHelper.instance.end_example(test_example)

        unless test_example.exception
          Cornucopia::Util::ReportBuilder.current_report.test_succeeded
        end
      end

      Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
      Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

      Cornucopia::Util::TestHelper.instance.record_test_end(test_example.full_description)
      Cornucopia::RSpecHelper.instance.last_reported_example = nil
    end

    puts "Cornucopia::Hook::after test time: #{time}" if Cornucopia::Util::Configuration.benchmark
  end
end