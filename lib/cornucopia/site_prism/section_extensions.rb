# frozen_string_literal: true

require 'active_support/concern'

module Cornucopia
  module SitePrism
    module SectionExtensions
      def initialize(*args)
        super(*args)

        self.owner_node = args[0].owner_node
      end
    end
  end
end
