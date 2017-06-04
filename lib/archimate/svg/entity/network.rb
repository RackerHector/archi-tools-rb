# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Network < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-network-badge"
        end
      end
    end
  end
end
