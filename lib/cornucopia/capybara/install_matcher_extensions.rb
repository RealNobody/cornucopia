$cornucopia_matcher_extension_installed = false unless defined? $cornucopia_matcher_extension_installed

if Object.const_defined?("Capybara") &&
    Capybara.const_defined?("Node") &&
    Capybara::Node.const_defined?("Document") &&
    !$cornucopia_matcher_extension_installed
  module Capybara
    module Node
      class Document
        alias_method :__cornucopia_orig_assert_selector, :assert_selector
        alias_method :__cornucopia_orig_assert_no_selector, :assert_no_selector
        alias_method :__cornucopia_orig_has_selector?, :has_selector?
        alias_method :__cornucopia_orig_has_no_selector?, :has_no_selector?

        include Cornucopia::Capybara::MatcherExtensions
      end
    end
  end
end

if Object.const_defined?("Capybara") &&
    Capybara.const_defined?("Node") &&
    Capybara::Node.const_defined?("Element") &&
    !$cornucopia_matcher_extension_installed
  module Capybara
    module Node
      class Element
        alias_method :__cornucopia_orig_assert_selector, :assert_selector
        alias_method :__cornucopia_orig_assert_no_selector, :assert_no_selector
        alias_method :__cornucopia_orig_has_selector?, :has_selector?
        alias_method :__cornucopia_orig_has_no_selector?, :has_no_selector?

        include Cornucopia::Capybara::MatcherExtensions
      end
    end
  end
end

if Object.const_defined?("Capybara") &&
    Capybara.const_defined?("Session") &&
    !$cornucopia_matcher_extension_installed
  $cornucopia_matcher_extension_installed = true
end