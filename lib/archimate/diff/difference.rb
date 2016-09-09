# frozen_string_literal: true
module Archimate
  module Diff
    # Difference defines a change between two entities within a model
    # * change kind (delete, insert, change)
    # * entity (reference to the entity or attribute)
    # * from (invalid for insert)
    # * to (invalid for delete)
    class Difference
      KIND = [:delete, :insert, :change].freeze

      attr_reader :kind
      attr_accessor :entity
      attr_accessor :from
      attr_accessor :to

      def self.context(entity)
        new(nil, entity)
      end

      def self.delete(entity, val)
        del = new(:delete, entity) do |d|
          d.from = val
        end
        yield del if block_given?
        del
      end

      def self.insert(entity, to)
        ins = new(:insert, entity) do |d|
          d.to = to
        end
        yield ins if block_given?
        ins
      end

      def self.change(entity, from, to)
        diff = new(:change, entity) do |d|
          d.from = from
          d.to = to
        end
        yield diff if block_given?
        diff
      end

      def initialize(kind, entity)
        @kind = kind
        @entity = entity
        @from = from
        @to = to
        yield self if block_given?
      end

      def apply(diffs)
        diffs.map do |d|
          diff = d.dup
          diff.entity = entity
          diff
        end
      end

      def ==(other)
        return false unless other.is_a?(Difference)
        @kind == other.kind &&
          @entity == other.entity &&
          @from == other.from &&
          @to == other.to
      end

      def to_s
        "#{fmt_kind}#{entity}: #{diff_description}"
      end

      def fmt_kind
        case kind
        when :delete
          HighLine.color("DELETE: ", :red)
        when :insert
          HighLine.color("INSERT: ", :green)
        else
          HighLine.color("CHANGE: ", :yellow)
        end
      end

      def diff_description
        case kind
        when :delete
          from.to_s
        when :insert
          to.to_s
        else
          ": #{from} -> #{to}"
        end
      end
    end
  end
end
