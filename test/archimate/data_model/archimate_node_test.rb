# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ArchimateNodeTest < Minitest::Test
      using DiffableArray

      def setup
        @base = build_model(with_elements: 3, with_relationships: 2, with_diagrams: 1)
        @diagram = @base.diagrams.first
        @remote_diagram = @diagram.with(name: "I wuz renamed")
        @local = @base.with(name: @base.name + "changed")
        @remote = @base.with(
          diagrams: @base.diagrams.map do |i|
            @diagram.id == i.id ? @remote_diagram : i
          end
        )
        assert @remote.diagrams.any? { |d| d.name == "I wuz renamed" }
      end

      def test_diff_on_primitive_attribute
        assert_equal(
          [Diff::Change.new(
            Archimate.node_reference(@diagram, "name"),
            Archimate.node_reference(@remote_diagram, "name")
          )],
          @diagram.diff(@remote_diagram)
        )
      end

      def test_diff_on_insert
        assert_equal(
          [Diff::Delete.new(Archimate.node_reference(@base))],
          @base.diff(nil)
        )
      end

      def test_primitive
        refute @base.primitive?
      end

      def test_delete
        subject = @base.clone.delete("name", @base.name)

        refute @base.name.nil?
        assert subject.name.nil?
      end

      def test_insert
        base = build_bounds(x: nil)
        subject = base.clone
        assert_nil subject.x

        subject.insert("x", 3.14)

        assert base.x.nil?
        assert_equal 3.14, subject.x
      end

      def test_change
        base = build_bounds(x: 1.0)
        subject = base.clone

        subject.change("x", 1.0, 3.14)

        assert_equal 1.0, base.x
        assert_equal 3.14, subject.x
      end

      def test_with
        m2 = @base.with(name: @base.name + "-changed")
        refute_equal @base, m2
        @base.to_h.keys.reject { |a| a == :name }.map(&:to_sym).each do |a|
          assert_equal @base.send(a), m2.send(a)
        end
      end

      def test_in_model
        @base.elements.each { |e| assert_equal @base, e.in_model }
      end

      def test_parent
        @base.elements.each { |e| assert_equal @base.elements, e.parent }
      end

      def test_assign_model
        @src_el = build_element
        @target_el = build_element
        @rel = build_relationship(source: @src_el.id, target: @src_el.id)
        @subject = build_source_connection(
          id: "abc123",
          type: "three",
          name: "test_name",
          source: "source",
          target: "target",
          relationship: "complicated"
        )
        @base = build_model(
          elements: [@src_el, @target_el],
          relationships: [@rel],
          diagrams: [
            build_diagram(
              children: [
                build_child(
                  source_connections: [@subject]
                )
              ]
            )
          ]
        )

        validate_in_model(@base)
      end

      def test_diff_with_changed_name
        m1 = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        m2 = m1.with(name: "#{m1.name}-changed")

        diffs = m1.diff(m2)

        assert_equal 1, diffs.size
        assert diffs.first.change?
      end

      def test_that_with_clones_passed_in_attributes
        m1 = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        _m2 = m1.with(elements: m1.elements)

        assert_same m1, m1.elements.parent
        m1.elements.each do |el|
          assert_same m1.elements, el.parent
          assert_same m1, el.in_model
        end
      end

      private

      def validate_in_model(node)
        case node
        when Dry::Struct
          assert_equal(
            @base.id, node.in_model&.id, "node #{node.class} in_model #{node.in_model.id} != #{@base.id}"
          ) unless node.is_a?(Model)
          node.to_h.values.each { |a| validate_in_model(a) }
        when Array
          node.each { |c| validate_in_model(c) }
        end
      end
    end
  end
end
