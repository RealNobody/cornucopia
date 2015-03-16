require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

Around do |scenario, block|
  seed_value = Cornucopia::Util::Configuration.seed ||
      100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

  scenario.instance_variable_set :@seed_value, seed_value

  Cornucopia::Capybara::FinderDiagnostics::FindAction.start_test

  block.call

  if scenario.failed?
    seed_value = scenario.instance_variable_get(:@seed_value)
    puts ("random seed for testing was: #{seed_value}")
  end
end

After do |scenario|
  if scenario.failed?
    Cornucopia::Util::ReportBuilder.current_report.
        within_section("Test Error: #{scenario.feature.title}:#{scenario.title}") do |report|
      configured_report = Cornucopia::Util::Configuration.report_configuration :cucumber

      configured_report.add_report_objects scenario: scenario, cucumber: self
      configured_report.generate_report(report)
    end

    # Cornucopia::DiagnosticsReportBuilder.current_report.within_section("Error:") do |report|
    #   report_generator = Cornucopia::Configuration.report_configuration(:cucumber)
    #
    #   report_generator.add_report_objects(self: self, scenario: scenario)
    #   report_generator.generate_report_for_object(report, diagnostics_name: scenario.file_colon_line)
    # end
  end
end

at_exit do
  Cornucopia::Util::ReportBuilder.current_report.close
end

Cornucopia::Util::ReportBuilder.new_report("cucumber_report")