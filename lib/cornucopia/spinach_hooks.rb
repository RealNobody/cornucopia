require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

Spinach.hooks.around_scenario do |scenario_data, step_definitions, &block|
  Cornucopia::Util::ReportBuilder.current_report.within_test("#{scenario_data.feature.name} : #{scenario_data.name}") do
    block.call
  end
end

Spinach.hooks.around_scenario do |scenario_data, step_definitions, &block|
  @reported_error   = false
  @running_scenario = scenario_data
  seed_value        = Cornucopia::Util::Configuration.seed ||
      100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

  scenario_data.instance_variable_set :@seed_value, seed_value

  Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
  Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

  begin
    block.call
  ensure
    @running_scenario = nil

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

    unless @reported_error
      Cornucopia::Util::ReportBuilder.current_report.test_succeeded
    end
    @reported_error = false
  end
end

Spinach.hooks.on_failed_step do |step_data, exception, location, step_definitions|
  debug_failed_step("Failure", step_data, exception, location, step_definitions)
end

Spinach.hooks.on_error_step do |step_data, exception, location, step_definitions|
  debug_failed_step("Error", step_data, exception, location, step_definitions)
end

def debug_failed_step(failure_description, step_data, exception, location, step_definitions)
  @reported_error = true

  seed_value = @running_scenario.instance_variable_get(:@seed_value)
  puts ("random seed for testing was: #{seed_value}")

  Cornucopia::Util::ReportBuilder.current_report.
      within_section("Test Error: #{@running_scenario.feature.name}") do |report|
    configured_report = Cornucopia::Util::Configuration.report_configuration :spinach

    configured_report.add_report_objects failure_description: "#{failure_description} at:, #{location[0]}:#{location[1]}",
                                         running_scenario:    @running_scenario,
                                         step_data:           step_data,
                                         exception:           exception,
                                         location:            location,
                                         step_definitions:    step_definitions

    configured_report.generate_report(report)
  end
end

Spinach.hooks.after_run do |status|
  Cornucopia::Util::ReportBuilder.current_report.close
end

Cornucopia::Util::ReportBuilder.new_report "spinach_report"