# frozen_string_literal: true

module Cornucopia
  module Util
    class MultipleExceptionFormatter
      def self.format_backtrace(value)
        return value.to_s unless value.is_a?(Array) && value.all? { |val| val.is_a?(Exception) }
        value_text = value.each_with_object([]) do |error, array|
          array << "Exception \##{array.length + 1}\n#{error.backtrace.join("\n")}"
        end.join("\n\n")

        Cornucopia::Util::ReportBuilder.pretty_format(value_text)
      end
    end
  end
end
