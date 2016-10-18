# frozen_string_literal: true
require "deep_clone"
require "hashdiff"

module Archimate
  module Diff
    # So it could be that if an item is deleted from 1 side
    # then it's actually the result of a de-duplication pass.
    # If so, then we could get good results by de-duping the
    # new side and comparing the results.
    class Merge
      attr_reader :conflicts
      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs
      attr_reader :base
      attr_reader :local
      attr_reader :remote
      attr_reader :merged
      attr_reader :message_io

      def initialize(base, local, remote, message_io = STDERR)
        @merged = DeepClone.clone base
        @base = IceNine.deep_freeze!(base)
        @local = IceNine.deep_freeze!(local)
        @remote = IceNine.deep_freeze!(remote)
        @conflicts = Conflicts.new
        @base_local_diffs = []
        @base_remote_diffs = []
        @message_io = message_io
      end

      def self.three_way(base, local, remote, message_io = STDERR)
        merge = Merge.new(base, local, remote, message_io)
        merge.three_way
        merge
      end

      def three_way
        message_io.puts "#{DateTime.now}: Computing base:local diffs"
        @base_local_diffs = Archimate.diff(base, local)

        bl_diffs = HashDiff.diff(Hashify.hashify(base), Hashify.hashify(local))
        message_io.puts "Local Diffs: #{bl_diffs.pretty_inspect}"
        br_diffs = HashDiff.diff(Hashify.hashify(base), Hashify.hashify(remote))
        message_io.puts "Remote Diffs: #{br_diffs.pretty_inspect}"

        message_io.puts "#{DateTime.now}: Computing base:remote diffs"
        @base_remote_diffs = Archimate.diff(base, remote)
        puts "three_way diffs found"
        puts (@base_remote_diffs + @base_local_diffs).map(&:entity).sort.uniq.join("\n")
        message_io.puts "#{DateTime.now}: Finding Conflicts"
        find_conflicts
        message_io.puts "#{DateTime.now}: Applying Diffs"
        @merged = apply_diffs(
          base_remote_diffs,
          apply_diffs(
            base_local_diffs,
            @merged
          )
        )
      end

      # TODO: All of the apply diff stuff belongs elsewhere?
      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        conflicts.filter_diffs(diffs).inject(model) do |m, diff|
          apply_diff(m, diff.with(entity: diff.entity.split("/")[1..-1].join("/")))
        end
      end

      # This is in need of refactoring
      def apply_diff(node, diff)
        path = diff.entity.split("/")
        attr_name = path.shift.to_sym
        inst_var_sym = "@#{attr_name}".to_sym
        attr_name = attr_name.to_sym

        if path.empty?
          # Intention here is to handle simple types like string, integer
          # node.with(attr_name => diff.to)
          # node.send(attr_name.to_s + "=", diff.to)
          node.instance_variable_set(inst_var_sym, diff.to)
          node
        else
          child_collection = node.send(attr_name)
          id = path.shift
          # Note: if the path is empty at this point, there's no more need to drill down
          if path.empty?
            if diff.delete?
              # node.with(attr_name => child_collection.reject { |_k, v| v == diff.from })
              node.send(attr_name).delete(diff.from)
              node
            else
              apply_child_changes(node, attr_name, id, diff.to)
            end
          else
            id = id.to_i if child_collection.is_a? Array
            child = child_collection[id]
            apply_child_changes(node, attr_name, id, apply_diff(child, diff.with(entity: path.join("/"))))
          end
        end
      end

      # TODO: this is a little hokey. I'd like to basically call a diff method based on the
      # type of the child collection here.
      def apply_child_changes(node, attr_name, id, child_value)
        child_collection = node.send(attr_name)
        case child_collection
        when Hash
          node.send(attr_name)[id] = child_value
          # node.with(attr_name => child_collection.merge(id => child_value))
        when Array
          # id = id.to_i
          # nu_collection = child_collection.dup
          # nu_collection[id.to_i] = child_value
          # node.with(attr_name => nu_collection)
          node.send(attr_name)[id.to_i] = child_value
        else
          raise "Type Error #{child_collection.class} unexpected for collection type"
        end
          node
      end

      # TODO: if we're looking at an Array, a conflict can be resolved by inserting both.
      def find_conflicts
        message_io.puts "#{DateTime.now}: find_diff_entity_conflicts"
        conflicts << find_diff_entity_conflicts
        message_io.puts "#{DateTime.now}: find_diagram_delete_update_conflicts"
        conflicts << find_diagram_delete_update_conflicts
        message_io.puts "#{DateTime.now}: find_deleted_elements_referenced_in_diagrams"
        conflicts << find_deleted_elements_referenced_in_diagrams
        message_io.puts "#{DateTime.now}: find_deleted_relationships_referenced_in_diagrams"
        conflicts << find_deleted_relationships_referenced_in_diagrams
        message_io.puts "#{DateTime.now}: find_deleted_relationships_with_updated_source_or_target"
        conflicts << find_deleted_relationships_with_updated_source_or_target
      end

      # Returns the set of conflicts caused by one diff set deleting a diagram
      # that the other diff set shows updated. This means that the diagram
      # probably shouldn't be deleted.
      #
      # TODO: should this be some other class?
      def find_diagram_delete_update_conflicts
        [base_local_diffs, base_remote_diffs].permutation(2).each_with_object([]) do |(diffs1, diffs2), a|
          a.concat(
            diagram_diffs_in_conflict(
              diagram_deleted_diffs(diffs1),
              Difference.diagram_updated_diffs(diffs2)
            )
          )
        end
      end

      # we want to make a Conflict for each parent_diff and set of child_diffs with the same diagram_id
      def diagram_diffs_in_conflict(parent_diffs, child_diffs)
        parent_diffs.each_with_object([]) do |parent_diff, a|
          conflicting_child_diffs = child_diffs.select { |child_diff| parent_diff.diagram_id == child_diff.diagram_id }
          a << Conflict.new(
            # TODO: we need a context here to know if it's a base to remote or remote to base conflict
            parent_diff, conflicting_child_diffs, "Diagram deleted in one change set modified in another"
          ) unless conflicting_child_diffs.empty?
        end
      end

      def find_diff_entity_conflicts
        @base_local_diffs.each_with_object([]) do |local_diff, cfx|
          conflicting_remote_diffs = @base_remote_diffs.select { |remote_diff| local_diff.entity == remote_diff.entity }
          cfx << Conflict.new(
            local_diff,
            conflicting_remote_diffs,
            "Conflicting changes"
          ) unless conflicting_remote_diffs.empty?
        end
      end

      def diagram_deleted_diffs(diffs)
        diffs.select { |i| i.delete? && i.diagram? }
      end

      # What are we looking for?
      # set1: extract element id of elements changed
      # set2: extract element ids of child archimateElements in diagrams
      # conflicts are the diffs with element id ref'd in deleted diagram
      ModelDiffs = Struct.new(:model, :diffs)

      def find_deleted_elements_referenced_in_diagrams
        [ModelDiffs.new(local, base_local_diffs),
         ModelDiffs.new(remote, base_remote_diffs)].permutation(2).each_with_object([]) do |(md1, md2), a|
          md2_diagram_diffs = md2.diffs.select(&:in_diagram?)
          a.concat(
            md1.diffs.select { |d| d.element? && d.delete? }.each_with_object([]) do |md1_diff, conflicts|
              conflicting_md2_diffs = md2_diagram_diffs.select do |md2_diff|
                md2.model.diagrams[md2_diff.diagram_id].element_references.include? md1_diff.element_id
              end
              conflicts << Conflict.new(md1_diff,
                                        conflicting_md2_diffs,
                                        "Elements referenced in deleted diagram") unless conflicting_md2_diffs.empty?
            end
          )
        end
      end

      def find_deleted_relationships_referenced_in_diagrams
        [ModelDiffs.new(local, base_local_diffs),
         ModelDiffs.new(remote, base_remote_diffs)].permutation(2).each_with_object([]) do |(md1, md2), a|
          md2_diagram_diffs = md2.diffs.select(&:in_diagram?)
          a.concat(
            md1.diffs.select { |d| d.relationship? && d.delete? }.each_with_object([]) do |md1_diff, conflicts|
              conflicting_md2_diffs = md2_diagram_diffs.select do |md2_diff|
                md2.model.diagrams[md2_diff.diagram_id].relationships.include? md1_diff.relationship_id
              end
              conflicts << Conflict.new(md1_diff,
                                        conflicting_md2_diffs,
                                        "Relationship referenced in deleted diagram") unless conflicting_md2_diffs.empty?
            end
          )
        end
      end

      def find_deleted_relationships_with_updated_source_or_target
        [ModelDiffs.new(local, base_local_diffs),
         ModelDiffs.new(remote, base_remote_diffs)].permutation(2).each_with_object([]) do |(md1, md2), a|
          md2_updated_elements = md2.diffs.select { |d| d.in_element? && !d.delete? }
          a.concat(
            md1.diffs.select { |d| d.relationship? && d.delete? }.each_with_object([]) do |md1_diff, conflicts|
              relationship = base.relationships[md1_diff.relationship_id]
              conflicting_md2_diffs = md2_updated_elements.select do |md2_diff|
                [relationship.source, relationship.target].include? md2_diff.element_id
              end
              conflicts << Conflict.new(md1_diff,
                                        conflicting_md2_diffs,
                                        "Source/Target referenced in deleted relationship") unless conflicting_md2_diffs.empty?
            end
          )
        end
      end
    end
  end
end
