require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

if Cucumber::VERSION.split[0].to_i >= 2
  After do |scenario, block|
    if scenario.failed?
      report_name = "Page Dump for: #{Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)}"

      Cornucopia::Capybara::PageDiagnostics.dump_details(section_label: report_name)
    end
  end

  Around do |scenario, block|
    test_name = Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)
    Cornucopia::Util::TestHelper.instance.record_test_start(test_name)

    seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    scenario.instance_variable_set :@seed_value, seed_value

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

    Cornucopia::Util::ReportBuilder.current_report.within_test("Scenario - #{test_name}") do
      block.call
    end

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

    Cornucopia::Util::TestHelper.instance.record_test_end(test_name)
  end
else
  Before do |scenario, block|
    test_name = Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)
    Cornucopia::Util::TestHelper.instance.record_test_start(test_name)

    seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    scenario.instance_variable_set :@seed_value, seed_value

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

    Cornucopia::Util::ReportBuilder.current_report.start_test(scenario, "Scenario - #{test_name}")
  end

  After do |scenario, block|
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
end

at_exit do
  Cornucopia::Util::ReportBuilder.current_report.close
end

Cornucopia::Util::ReportBuilder.new_report("cucumber_report")