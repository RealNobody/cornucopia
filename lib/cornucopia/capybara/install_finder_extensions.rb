$cornucopia_finder_extension_installed = false unless defined? $cornucopia_finder_extension_installed

if Object.const_defined?("Capybara") &&
    Capybara.const_defined?("Node") &&
    Capybara::Node.const_defined?("Document") &&
    !$cornucopia_finder_extension_installed
  module Capybara
    module Node
      class Document
        alias_method :__cornucopia_orig_find, :find
        alias_method :__cornucopia_orig_all, :all

        include Cornucopia::Capybara::FinderExtensions
      end
    end
  end
end

if Object.const_defined?("Capybara") &&
    Capybara.const_defined?("Node") &&
    Capybara::Node.const_defined?("Element") &&
    !$cornucopia_finder_extension_installed
  module Capybara
    module Node
      class Element
        alias_method :__cornucopia_orig_find, :find
        alias_method :__cornucopia_orig_all, :all

        include Cornucopia::Capybara::FinderExtensions

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
end

if Object.const_defined?("Capybara") &&
    Capybara.const_defined?("Session") &&
    !$cornucopia_finder_extension_installed
  $cornucopia_finder_extension_installed = true

  module Capybara
    class Session
      alias_method :__cornucopia_orig_find, :find
      alias_method :__cornucopia_orig_all, :all

      include Cornucopia::Capybara::FinderExtensions

      # This function uses Capybara's synchronize function to evaluate a block until
      # it becomes true.
      def synchronize_test(seconds=Capybara.default_wait_time, options = {}, &block)
        document.synchronize(seconds, options) do
          raise ::Capybara::ElementNotFound unless block.yield
        end
      end
    end
  end
end