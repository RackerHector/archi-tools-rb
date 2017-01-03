# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DiffablePrimitiveTest < Minitest::Test
      using DiffablePrimitive

      def setup
        # @base = build_model(with_relationships: 2, with_diagrams: 1)
        # @diagram = @base.diagrams.first
        # @local = @base.with(name: @base.name + "changed")
        # @remote = @base.with(
        #   diagrams: @base.diagrams.map do |i|
        #     @diagram.id == i.id ? i.with(name: "I wuz renamed") : i
        #   end
        # )
        # assert @remote.diagrams.any? { |d| d.name == "I wuz renamed" }
        @model = build_model
        @subject = "sample"
      end

      def test_assign_model
        @subject.assign_model(@model)
      end

      def test_assign_parent
        @subject.assign_parent(@model)
      end

      def test_primitive
        assert @subject.primitive?
      end

      def test_diff_no_changes
        assert_empty @subject.diff("sample", @model, @model, "name")
      end

      def test_diff_delete
        assert_equal(
          [Diff::Delete.new(Archimate.node_reference(@model, "name"))],
          @subject.diff(nil, @model, @model, "name")
        )
      end

      def test_diff_change
        assert_equal(
          [Diff::Change.new(Archimate.node_reference(@model, "name"), Archimate.node_reference(@model, "name"))],
          @subject.diff("primal", @model, @model, "name")
        )
      end
    end
  end
end
