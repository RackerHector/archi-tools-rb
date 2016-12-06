# frozen_string_literal: true

require 'forwardable'
require 'archimate/diff/conflicts/base_conflict'
require 'archimate/diff/conflicts/deleted_items_child_updated_conflict'
require 'archimate/diff/conflicts/deleted_items_referenced_conflict'
require 'archimate/diff/conflicts/path_conflict'

module Archimate
  module Diff
    class Conflicts
      extend Forwardable

      attr_reader :aio
      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs

      def_delegator :@conflicts, :empty?
      def_delegator :@conflicts, :size
      def_delegator :@conflicts, :first
      def_delegator :@conflicts, :map
      def_delegator :@conflicts, :each

      def initialize(base_local_diffs, base_remote_diffs, aio)
        @base_local_diffs = base_local_diffs
        @base_remote_diffs = base_remote_diffs
        @aio = aio
        @conflict_finders = [PathConflict, DeletedItemsChildUpdatedConflict, DeletedItemsReferencedConflict]
        @conflicts = nil
        @conflicting_diffs = nil
        @unconflicted_diffs = nil
      end

      # TODO: refactor this method elsewhere
      def resolve
        aio.debug "Filtering out #{conflicts.size} conflicts from #{base_local_diffs.size + base_remote_diffs.size} diffs"

        aio.debug "Remaining diffs #{unconflicted_diffs.size}"

        conflicts.each_with_object(unconflicted_diffs) do |conflict, diffs|
          diffs.concat(aio.resolve_conflict(conflict))
        end
      end

      def conflicts
        @conflicts ||= find_conflicts
      end

      def conflicting_diffs
        @conflicting_diffs ||= conflicts.map(&:diffs).flatten
      end

      def unconflicted_diffs
        @unconflicted_diffs ||=
          (base_remote_diffs + base_local_diffs) - conflicting_diffs
      end

      def to_s
        "Conflicts:\n\n#{conflicts.map(&:to_s).join("\n\n")}\n"
      end

      private

      def find_conflicts
        @conflicts = []
        @conflict_finders.each do |cf_class|
          cf = cf_class.new(base_local_diffs, base_remote_diffs, aio)
          aio.debug cf.describe
          @conflicts.concat(cf.conflicts)
        end
        @conflicts
      end
    end
  end
end
