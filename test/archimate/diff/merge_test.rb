# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    # Ok - here's the plan
    # Produce two sets of Differences on two models
    # Use cases:
    # 1. [x] Inserts (always good)
    # 2. [x] change on the same path == conflict to be resolved
    # 3. [x] change on diff paths == ok
    # 4. delete: diagram (ok) unless other changed that diagram - then conflict
    # 5. delete: relationship (ok - if source & target also deleted & not referenced by remaining diagrams)
    # 6. delete: element (ok - if not referenced by remaining diagrams)
    # 7. merged: duplicate elements where merged into one
    class MergeTest < Minitest::Test
      attr_reader :merge
      attr_reader :base
      attr_reader :base_el1
      attr_reader :base_el2
      attr_reader :base_rel1
      attr_reader :base_rel2

      def mutate_model_element(model, element, label_suffix)
        DataModel.model_insert_element(
          model,
          element.with(label: element.label + label_suffix)
        )
      end

      def setup
        @merge = Merge.new
        @base = build_model(with_relationships: 2)
        @base_el1 = base.elements[base.elements.keys.first]
        @base_el2 = base.elements[base.elements.keys.last]
        @base_rel1 = base.relationships[base.relationships.keys.first]
        @base_rel2 = base.relationships[base.relationships.keys.last]
      end

      def test_independent_changes_element
        local_el = base_el1.with(label: "#{base_el1.label}-local")
        remote_el = base_el2.with(label: "#{base_el2.label}-remote")
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        actual = merge.three_way(base, local, remote)

        assert_empty merge.conflicts
        assert_includes actual.elements.values, local_el
        assert_includes actual.elements.values, remote_el
        refute_equal base, actual
      end

      def test_independent_changes_element_documentation
        local_el = base_el1.with(documentation: build_documentation)
        remote_el = base_el2.with(documentation: build_documentation)
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        actual = merge.three_way(base, local, remote)

        assert_empty merge.conflicts
        assert_includes actual.elements.values, local_el
        assert_includes actual.elements.values, remote_el
        refute_equal base, actual
      end

      def test_both_insert_element_documentation
        skip("Re-enable after a better conflict detector is written")
        doc1 = build_documentation
        doc2 = build_documentation
        local_el = base_el1.with(documentation: doc1)
        remote_el = base_el1.with(documentation: doc2)
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        actual = merge.three_way(base, local, remote)

        assert_empty merge.conflicts
        assert_includes actual.elements[base_el1.id].documentation, doc1[0]
        assert_includes actual.elements[base_el1.id].documentation, doc2[0]
        refute_equal base, actual
      end

      def test_independent_changes_relationship
        local_rel = base_rel1.with(name: "#{base_rel1.name}-local")
        remote_rel = base_rel2.with(name: "#{base_rel2.name}-remote")
        local = base.insert_relationship(local_rel)
        remote = base.insert_relationship(remote_rel)

        actual = merge.three_way(base, local, remote)

        assert_empty merge.conflicts
        assert_includes actual.relationships.values, local_rel
        assert_includes actual.relationships.values, remote_rel
        refute_equal base, actual
      end

      def test_conflict
        local_el = base_el1.with(label: "#{base_el1.label}-local")
        remote_el = base_el1.with(label: "#{base_el1.label}-remote")
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        actual = merge.three_way(base, local, remote)

        assert_equal base, actual
        assert_equal 1, merge.conflicts.size
        assert_equal [merge.base_local_diffs[0], merge.base_remote_diffs[0]], merge.conflicts.first
      end

      def test_insert_in_remote
        local = base
        iel = build_element
        remote = base.insert_element(iel)
        actual = merge.three_way(base, local, remote)
        assert_equal remote, actual
        refute_equal base, actual
        refute_equal base, remote
        refute_equal local, remote
      end

      def test_insert_in_local
        remote = base
        iel = build_element
        local = base.insert_element(iel)
        actual = merge.three_way(base, local, remote)
        assert_equal local, actual
        assert_equal base, remote
        refute_equal base, local
        refute_equal local, remote
      end

      def test_apply_diff_insert_element
        m1 = build_model(with_elements: 3)
        m2 = m1.insert_element(build_element)
        m3 = merge.three_way(m1, m2, m1)
        assert_equal m2, m3
        refute_equal m1, m2
        refute_equal m1, m3
      end

      def test_apply_diff_on_model_attributes
        m1 = build_model
        m2 = m1.with(id: Faker::Number.hexadecimal(8))
        m3 = merge.three_way(m1, m2, m1)
        assert_equal 1, merge.base_local_diffs.size
        assert_equal m2, m3
      end

      def test_no_changes
        local = Archimate::DataModel::Model.new(base.to_h)
        remote = Archimate::DataModel::Model.new(base.to_h)

        merged = merge.three_way(base, local, remote)

        assert_equal base, merged
        assert_equal local, merged
        assert_equal remote, merged
      end

      def test_find_diagram_delete_update_conflicts
        diagram = build_diagram
      end
    end
  end
end
