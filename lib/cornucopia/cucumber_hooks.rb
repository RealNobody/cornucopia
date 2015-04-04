require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

Around do |scenario, block|
  seed_value = Cornucopia::Util::Configuration.seed ||
      100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

  scenario.instance_variable_set :@seed_value, seed_value

  Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
  Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

  Cornucopia::Util::ReportBuilder.current_report.within_test("#{scenario.feature.title} : #{scenario.title}") do
    block.call
  end

  if scenario.failed?
    seed_value = scenario.instance_variable_get(:@seed_value)
    puts ("random seed for testing was: #{seed_value}")

    Cornucopia::Util::ReportBuilder.current_report.
        within_section("Test Error: #{scenario.feature.title}:#{scenario.title}") do |report|
      configured_report = Cornucopia::Util::Configuration.report_configuration :cucumber

      configured_report.add_report_objects scenario: scenario, cucumber: self
      configured_report.generate_report(report)
    end
  else
    Cornucopia::Util::ReportBuilder.current_report.test_succeeded
  end

  Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
  Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages
end

at_exit do
  Cornucopia::Util::ReportBuilder.current_report.close
end

Cornucopia::Util::ReportBuilder.new_report("cucumber_report")