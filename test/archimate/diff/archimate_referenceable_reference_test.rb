# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateReferenceableReferenceTest < Minitest::Test
      using DataModel::DiffableArray
      def setup
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_folders: 4)
        @subject = ArchimateReferenceableReference.new(@model.elements.first)

        @other = @model.with(elements: [build_element] + @model.elements)
      end

      def test_initialize
        assert_same @model.elements.first, @subject.archimate_node
      end

      def test_lookup_in_model_for_element
        assert_same @other.elements[1], @subject.lookup_in_model(@other)
      end

      def test_lookup_parent_in_model
        assert_same @other.elements, @subject.lookup_parent_in_model(@other)
      end

      def test_parent
        assert_equal @model.elements, @subject.parent
      end

      def test_to_s
        assert_equal @model.elements[0].to_s, @subject.to_s
      end

      def test_value
        assert_same @model.elements[0], @subject.value
      end
    end
  end
end
