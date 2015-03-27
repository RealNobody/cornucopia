require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_matcher_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

RSpec.configure do |config|
  config.seed = Cornucopia::Util::Configuration.order_seed if Cornucopia::Util::Configuration.order_seed

  config.before(:suite) do |*args|
    Cornucopia::Util::ReportBuilder.new_report("rspec_report")
  end

  config.after(:suite) do
    Cornucopia::Util::ReportBuilder.current_report.close
  end

  config.around(:each) do |example|
    @seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    srand(@seed_value)

    Cornucopia::Capybara::FinderDiagnostics::FindAction.start_test

    test_example = example.example if example.respond_to?(:example)
    test_example ||= self.example if self.respond_to?(:example)

    Cornucopia::Util::ReportBuilder.current_report.within_test(test_example.full_description) do
      example.run

      if (test_example.exception)
        puts ("random seed for testing was: #{@seed_value}")

        Cornucopia::Util::ReportBuilder.current_report.
            within_section("Test Error: #{test_example.full_description}") do |report|
          configured_report = Cornucopia::Util::Configuration.report_configuration :rspec

          configured_report.add_report_objects example: test_example, rspec: RSpec
          configured_report.generate_report(report)
        end
      end
    end
  end
end