# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ModelDiffTest < Minitest::Test
      BASE = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
      DIFF1 = File.join(TEST_EXAMPLES_FOLDER, "diff1.archimate")

      def test_equivalent
        model1 = Archimate::ArchiFileReader.read(BASE)
        model2 = Archimate::ArchiFileReader.read(BASE)
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_empty model_diffs
      end

      def test_diff_model_name
        model1 = Archimate::Model::Model.new("123", "base")
        model2 = Archimate::Model::Model.new("123", "change")
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_equal [Difference.new(:change, :name, :model, "base", "change")], model_diffs
      end

      def test_diff_model_id
        model1 = Archimate::Model::Model.new("123", "base")
        model2 = Archimate::Model::Model.new("321", "base")
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_equal [Difference.new(:change, :id, :model, "123", "321")], model_diffs
      end

      def test_diff_model_documentation
        model1 = Archimate::Model::Model.new("123", "base") do |m|
          m.documentation = %w(documentation1)
        end
        model2 = Archimate::Model::Model.new("123", "base") do |m|
          m.documentation = %w(documentation2)
        end
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_equal(
          Difference.context(:documentation, :model).apply(
            [
              Difference.delete("documentation1", nil, nil, 0),
              Difference.insert("documentation2", nil, nil, 0)
            ]
          ), model_diffs
        )
      end

      def test_diff_model_elements_same
        element_list = build_list(:element, 3)
        element_hash = element_list.each_with_object({}) { |i, a| a[i.identifier] = i }
        model1 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash
        end
        model2 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash
        end
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_empty(model_diffs)
      end

      def test_diff_model_elements_insert
        element_list = build_list(:element, 3)
        element_hash = element_list.each_with_object({}) { |i, a| a[i.identifier] = i }
        model1 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash.dup
        end
        ins_el = build(:element)
        element_hash[ins_el.identifier] = ins_el
        model2 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash
        end
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_equal(
          Difference.context(:elements, :model).apply(
            [
              Difference.insert(ins_el) { |d| d.index = 3 }
            ]
          ), model_diffs
        )
      end
    end
  end
end
