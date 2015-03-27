module Cornucopia
  module Util
    class FileAsset
      class << self
        def asset(asset_name)
          @@asset_list                    ||= {}
          @@asset_list[asset_name.to_sym] = FileAsset.new(asset_name) unless @@asset_list[asset_name.to_sym]
          @@asset_list[asset_name.to_sym]
        end
      end

      def initialize(asset_name)
        @asset_name = asset_name
      end

      def body=(asset_body)
        @asset_body = asset_body
      end

      def body
        unless @asset_body
          self.source_file = path
        end

        @asset_body
      end

      def source_file=(source_file_name)
        # We read the file into memory in case the file moves or is temporary.
        @asset_body = File.read(source_file_name)
      end

      def add_file(output_location)
        unless (File.exists?(output_location))
          create_file(output_location)
        end
      end

      def create_file(output_location)
        if @asset_body
          File.open(output_location, "w+") do |write_file|
            write_file << @asset_body
          end
        else
          FileUtils.cp path, output_location
        end
      end

      def path
        File.absolute_path(File.join(File.dirname(__FILE__), "../source_files/", @asset_name))
      end
    end
  end
end