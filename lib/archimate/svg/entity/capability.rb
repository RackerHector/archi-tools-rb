# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Capability < RoundedRectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-capability-badge"
        end
      end
    end
  end
end
