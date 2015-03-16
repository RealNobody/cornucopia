require ::File.expand_path("../cornucopia", File.dirname(__FILE__))
load ::File.expand_path("capybara/install_finder_extensions.rb", File.dirname(__FILE__))
load ::File.expand_path("site_prism/install_element_extensions.rb", File.dirname(__FILE__))

Spinach.hooks.before_scenario do |scenario, step_definitions|
  @running_scenario = scenario
  seed_value        = Cornucopia::Util::Configuration.seed ||
      100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

  scenario.instance_variable_set :@seed_value, seed_value

  Cornucopia::Capybara::FinderDiagnostics::FindAction.start_test
end

Spinach.hooks.after_scenario do |scenario, step_definitions|
  @running_scenario = nil
end

Spinach.hooks.on_failed_step do |step_data, exception, location, step_definitions|
  debug_failed_step("Failure", step_data, exception, location, step_definitions)
end

Spinach.hooks.on_error_step do |step_data, exception, location, step_definitions|
  debug_failed_step("Error", step_data, exception, location, step_definitions)
end

def debug_failed_step(failure_description, step_data, exception, location, step_definitions)
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

  # Cornucopia::Util::ReportBuilder.current_report.within_section("#{failure_description}:") do |report|
  #   report_generator = Cornucopia::Configuration.report_configuration(:spinach)
  #
  #   report_generator.add_report_objects(failure_description: "#{failure_description} at:, #{location[0]}:#{location[1]}",
  #                                       step_data:        step_data,
  #                                       exception:        exception,
  #                                       location:         location,
  #                                       step_definitions: step_definitions,
  #                                       running_scenario: @running_scenario
  #   )
  #   report_generator.generate_report_for_object(report, diagnostics_name: "#{step_data.name}:#{step_data.line}")
  # end
end

Spinach.hooks.after_run do |status|
  Cornucopia::Util::ReportBuilder.current_report.close
end

Cornucopia::Util::ReportBuilder.new_report "spinach_report"