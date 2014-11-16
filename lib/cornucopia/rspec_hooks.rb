require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

RSpec.configure do |config|
  config.before(:all) do
    Cornucopia::Util::ReportBuilder.new_report("rspec_report")
  end

  config.after(:all) do
    Cornucopia::Util::ReportBuilder.current_report.close
  end

  config.around(:each) do |example|
    @seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    srand(@seed_value)

    example.run

    test_example = example.example if example.respond_to?(:example)
    test_example ||= self.example if self.respond_to?(:example)
    if (test_example.exception)
      puts ("random seed for testing was: #{@seed_value}")
    end
  end

  config.after(:each) do |example|
    example = example.example if example.respond_to?(:example)
    if (example.exception)
      Cornucopia::Util::ReportBuilder.current_report.
          within_section("Test Error: #{example.full_description}") do |report|
        configured_report = Cornucopia::Util::Configuration.report_configuration :rspec

        configured_report.add_report_objects example: example
        configured_report.generate_report(report)
      end

      # Cornucopia::Util::ReportBuilder.current_report.within_section("Error:") do |report|
      #   report_generator = Cornucopia::Configuration.report_configuration(:rspec)
      #
      #   report_generator.add_report_objects(self: self)
      #   report_generator.generate_report_for_object(report, diagnostics_name: @example.full_description)
      # end
    end
  end
end