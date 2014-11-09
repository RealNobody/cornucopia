$cornucopia_element_extension_installed = false unless defined? $cornucopia_element_extension_installed

if Object.const_defined?("SitePrism") &&
    ::SitePrism.const_defined?("Page") &&
    !$cornucopia_element_extension_installed
  module ::SitePrism
    class Page
      include Cornucopia::SitePrism::ElementExtensions
    end
  end
end

if Object.const_defined?("SitePrism") &&
    ::SitePrism.const_defined?("Section") &&
    !$cornucopia_element_extension_installed
  $cornucopia_element_extension_installed = true

  module ::SitePrism
    class Section
      include Cornucopia::SitePrism::ElementExtensions
    end
  end
end