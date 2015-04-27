require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

if Cucumber::VERSION.split[0].to_i >= 2
  Around do |scenario, block|
    seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    scenario.instance_variable_set :@seed_value, seed_value

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

    test_name = ""
    if scenario.respond_to?(:feature)
      test_name = "#{scenario.feature.title} : #{scenario.title}"
    elsif scenario.respond_to?(:line)
      test_name = "Scenario - Line: #{scenario.line}"
    else
      test_name = "Scenario - Unknown"
    end
    Cornucopia::Util::ReportBuilder.current_report.within_test(test_name) do
      block.call
    end

    if scenario.failed?
      seed_value = scenario.instance_variable_get(:@seed_value)
      puts ("random seed for testing was: #{seed_value}")

      report_name = ""
      if scenario.respond_to?(:feature)
        report_name = "Test Error: #{scenario.feature.title}:#{scenario.title}"
      else
        report_name = "Line - #{scenario.line}"
      end
      Cornucopia::Util::ReportBuilder.current_report.within_section(report_name) do |report|
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
  end
else
  Before do |scenario, block|
    seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    scenario.instance_variable_set :@seed_value, seed_value

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

    test_name = ""
    if scenario.respond_to?(:feature)
      test_name = "#{scenario.feature.title} : #{scenario.title}"
    elsif scenario.respond_to?(:line)
      test_name = "Scenario - Line: #{scenario.line}"
    else
      test_name = "Scenario - Unknown"
    end
    Cornucopia::Util::ReportBuilder.current_report.start_test(scenario, test_name)
  end

  After do |scenario, block|
    if scenario.failed?
      seed_value = scenario.instance_variable_get(:@seed_value)
      puts ("random seed for testing was: #{seed_value}")

      report_name = ""
      if scenario.respond_to?(:feature)
        report_name = "Test Error: #{scenario.feature.title}:#{scenario.title}"
      else
        report_name = "Line - #{scenario.line}"
      end
      Cornucopia::Util::ReportBuilder.current_report.within_section(report_name) do |report|
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
  end
end

at_exit do
  Cornucopia::Util::ReportBuilder.current_report.close
end

Cornucopia::Util::ReportBuilder.new_report("cucumber_report")