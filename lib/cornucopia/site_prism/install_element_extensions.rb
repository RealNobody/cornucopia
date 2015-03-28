$cornucopia_element_extension_installed = false unless defined? $cornucopia_element_extension_installed

if Object.const_defined?("SitePrism") &&
    ::SitePrism.const_defined?("Page") &&
    !$cornucopia_element_extension_installed
  module ::SitePrism
    class Page
      include Cornucopia::SitePrism::ElementExtensions

      ::Capybara::Session::DSL_METHODS.each do |method|
        alias_method "__cornucopia_orig_#{method}".to_sym, method

        define_method method do |*args, &block|
          if @__corunucopia_base_node
            @__corunucopia_base_node.send method, *args, &block
          else
            send "__cornucopia_orig_#{method}", *args, &block
          end
        end
      end
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

      alias_method :__corunucopia_orig_intialize, :initialize
      def initialize(*args)
        __corunucopia_orig_intialize(*args)

        self.owner_node = args[0].owner_node
      end

      ::Capybara::Session::DSL_METHODS.each do |method|
        alias_method "__cornucopia_orig_#{method}".to_sym, method

        define_method method do |*args, &block|
          if @__corunucopia_base_node
            @__corunucopia_base_node.send method, *args, &block
          else
            send "__cornucopia_orig_#{method}", *args, &block
          end
        end
      end
    end
  end
end