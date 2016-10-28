# frozen_string_literal: true

require ::File.expand_path('report_builder', File.dirname(__FILE__))

module Cornucopia
  module Util
    class CucumberFormatter
      def self.format_location(value)
        Cornucopia::Util::ReportBuilder.pretty_format("#{value.file}:#{value.line}")
      end
    end
  end
end
