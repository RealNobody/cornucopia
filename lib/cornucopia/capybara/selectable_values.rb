# frozen_string_literal: true

require ::File.expand_path("../util/configuration", File.dirname(__FILE__))
require ::File.expand_path("finder_diagnostics", File.dirname(__FILE__))

require "active_support/concern"

module Cornucopia
  module Capybara
    module SelectableValues
      extend ActiveSupport::Concern

      # select_value finds the option with the value #value then calls select_option on that item.
      #
      # select_value only works on select boxes.
      def select_value(values)
        raise "select_value is only valid for select items" unless self.tag_name == "select"

        if values.is_a?(Array)
          values.each do |value|
            html_safe_value = "".html_safe + value.to_s
            self.find("option[value=\"#{html_safe_value}\"]", visible: false).select_option
          end
        else
          html_safe_value = "".html_safe + values.to_s
          self.find("option[value=\"#{html_safe_value}\"]", visible: false).select_option
        end
      end

      # value_text returns the text for the selected items in the select box instead of the value(s)
      #
      # value_text only works on select boxes.
      def value_text
        raise "value_text is only valid for select items" unless self.tag_name == "select"

        values = self.value
        if values.is_a?(Array)
          values.map do |value|
            self.find("option[value=\"#{value}\"]", visible: false).text
          end
        else
          self.find("option[value=\"#{values}\"]", visible: false).text
        end
      end
    end
  end
end
