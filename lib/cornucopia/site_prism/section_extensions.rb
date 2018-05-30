# frozen_string_literal: true

require 'active_support/concern'

module Cornucopia
  module SitePrism
    module SectionExtensions
      extend ActiveSupport::Concern

      included do |base|
        base.class_exec do
          alias :__cornucopia_site_prism_orig_initialize :initialize

          def initialize(*args)
            __cornucopia_site_prism_orig_initialize(*args)

            self.owner_node = args[0].owner_node
          end
        end
      end
    end
  end
end
