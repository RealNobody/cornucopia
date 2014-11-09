module Cornucopia
  module Util
    # This is a stupid little settings class
    # Basicaly, anything you send to it is put into a hash or returned from a hash.
    class GenericSettings
      def initialize
        @settings_hash = {}
      end

      def method_missing(method_sym, *arguments, &block)
        if self.respond_to?("super__#{method_sym}".to_sym)
          super
        else
          if method_sym.to_s[-1] == "="
            raise "wrong number of arguments (#{arguments.length} for 1)" if !arguments || arguments.length != 1
            raise "block not accepted" if block

            @settings_hash[method_sym.to_s[0..-2].to_sym] = arguments[0]
          else
            raise "too many arguments (#{arguments.length} for 0)" if arguments && arguments.length > 0
            raise "block not accepted" if block
            @settings_hash[method_sym]
          end
        end
      end

      def respond_to?(method_sym, include_private = false)
        method_name = method_sym.to_s
        if method_name[0.."super__".length - 1] == "super__"
          super(method_sym["super__".length..-1].to_sym, include_private)
        else
          true
        end
      end
    end
  end
end