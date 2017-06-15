# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class NodeShapeTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.nodes.first
          # @subject = NodeShape.new(@child, build_bounds)
        end

        def xtest_badge
          assert_nil @subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
