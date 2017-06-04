# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class ArtifactTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.children.first
        end

        def test_badge
          subject = Artifact.new(@child, build_bounds)
          refute_nil subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
