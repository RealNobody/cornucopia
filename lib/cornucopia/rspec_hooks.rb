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

  config.before(:all) do
    @context_seed_value = Cornucopia::Util::Configuration.context_seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    srand(@context_seed_value)
  end

  # Capybara resets the page in an after or around block before the around diagnostics can get around to dumping it
  # so by adding an after block here, we can dump the Capybara results if there is a problem.
  config.after(:each) do |example|
    test_example = example.example if example.respond_to?(:example)
    test_example ||= self.example if self.respond_to?(:example)
    test_example ||= example

    if (test_example.exception)
      report = Cornucopia::Util::ReportBuilder.current_report

      report.within_section("Page Dump for: #{test_example.full_description}") do |report|
        report.within_hidden_table do |table|
          Cornucopia::Util::ReportTable.new(
              report_table:         nil,
              nested_table:         table,
              suppress_blank_table: true) do |sub_tables|
            Cornucopia::Capybara::PageDiagnostics.dump_details_in_table(report, sub_tables)
          end
        end
      end
    end
  end

  config.around(:each) do |example|
    @seed_value = Cornucopia::Util::Configuration.seed ||
        100000000000000000000000000000000000000 + rand(899999999999999999999999999999999999999)

    srand(@seed_value)

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages

    test_example = example.example if example.respond_to?(:example)
    test_example ||= self.example if self.respond_to?(:example)
    test_example ||= example

    Cornucopia::Util::ReportBuilder.current_report.within_test(test_example.full_description) do
      example.run

      if (test_example.exception)
        puts ("random seed for testing was: #{@context_seed_value}, #{@seed_value}")

        Cornucopia::Util::ReportBuilder.current_report.
            within_section("Test Error: #{test_example.full_description}") do |report|
          configured_report = Cornucopia::Util::Configuration.report_configuration :rspec

          configured_report.add_report_objects example: test_example, rspec: RSpec
          configured_report.generate_report(report)
        end
      else
        Cornucopia::Util::ReportBuilder.current_report.test_succeeded
      end
    end

    Cornucopia::Capybara::FinderDiagnostics::FindAction.clear_diagnosed_finders
    Cornucopia::Capybara::PageDiagnostics.clear_dumped_pages
  end
end