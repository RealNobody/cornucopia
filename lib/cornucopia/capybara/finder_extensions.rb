require ::File.expand_path("../util/configuration", File.dirname(__FILE__))
require ::File.expand_path("finder_diagnostics", File.dirname(__FILE__))

module Cornucopia
  module Capybara
    module FinderExtensions
      def find(*args)
        __cornucopia_finder_function(:find, *args)
      end

      def all(*args)
        __cornucopia_finder_function(:all, *args)
      end

      def __cornucopia_finder_function(finder_function, *args)
        retry_count = 0
        result      = nil

        support_options = __cornucopia__extract_support_options(*args)

        begin
          retry_count += 1
          result      = send("__cornucopia_orig_#{finder_function}", *args)
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          retry if __cornucopia__retry_finder(retry_count, support_options)

          result = __cornucopia__analyze_finder(finder_function, support_options, *args)
        rescue Exception
          result = __cornucopia__analyze_finder(finder_function, support_options, *args)
        end

        result
      end

      private

      def __cornucopia__extract_support_options(*args)
        support_options = {}

        if args[-1].is_a?(Hash)
          support_options[:__cornucopia_no_analysis]      = args[-1].delete(:__cornucopia_no_analysis)
          support_options[:__cornucopia_retry_with_found] = args[-1].delete(:__cornucopia_retry_with_found)
          # support_options[:__cornucopia_alternate_retry]  = args[-1].delete(:__cornucopia_alternate_retry)
        end

        support_options
      end

      def __cornucopia__analyze_finder(function_name, support_options, *args)
        return_value = nil
        error        = $!

        if !support_options[:__cornucopia_no_analysis] &&
            (Cornucopia::Util::Configuration.analyze_find_exceptions ||
                support_options[:__cornucopia_retry_with_found])
          # || support_options[:__cornucopia_alternate_retry])
          find_action = Cornucopia::Capybara::FinderDiagnostics::FindAction.new(self, {}, function_name, *args)

          if find_action.perform_analysis(Cornucopia::Util::Configuration.retry_with_found ||
                                              support_options[:__cornucopia_retry_with_found])
            # Cornucopia::Util::Configuration.alternate_retry ||
            #     support_options[:__cornucopia_alternate_retry])
            return_value = find_action.return_value
          else
            raise error
          end
        else
          raise error
        end

        return_value
      end

      def __cornucopia__retry_finder(retry_count, support_options)
        retry_count <= Cornucopia::Util::Configuration.selenium_cache_retry_count &&
            !support_options[:__cornucopia_no_analysis]
      end
    end
  end
end

load ::File.expand_path("install_finder_extensions.rb", File.dirname(__FILE__))