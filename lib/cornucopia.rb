require "benchmark"

time = Benchmark.measure do
  require "cornucopia/version"

  require "active_support"
  require "active_support/core_ext"

  require "cornucopia/util/configuration"
  require "cornucopia/util/configured_report"
  require "cornucopia/util/generic_settings"
  require "cornucopia/util/file_asset"
  require "cornucopia/util/log_capture"
  require "cornucopia/util/pretty_formatter"
  require "cornucopia/util/report_builder"
  require "cornucopia/util/report_table"
  require "cornucopia/util/test_helper"
  require "cornucopia/capybara/finder_diagnostics"
  require "cornucopia/capybara/page_diagnostics"
  require "cornucopia/capybara/finder_extensions"
  require "cornucopia/capybara/matcher_extensions"
  require "cornucopia/capybara/selectable_values"
  require "cornucopia/capybara/synchronizable"
  require "cornucopia/site_prism/element_extensions"
  require "cornucopia/site_prism/page_application"
  require "cornucopia/site_prism/section_extensions"

  require "cornucopia/capybara/install_extensions"
  require "cornucopia/site_prism/install_extensions"
end

puts "Cornucopia load time: #{time}"

module Cornucopia
end