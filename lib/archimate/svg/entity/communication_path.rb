# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class CommunicationPath < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-communication-path-badge"
        end
      end
    end
  end
end
