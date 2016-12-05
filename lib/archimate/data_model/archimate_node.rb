# frozen_string_literal: true
module Archimate
  module DataModel
    class ArchimateNode < Dry::Struct
      using DiffablePrimitive
      using DiffableArray

      constructor_type :schema

      def with(options = {})
        self.class.new(
          struct_instance_variables
            .each_with_object({}) { |i, a| a[i] = send(i) }
            .merge(options)
            .each_with_object({}) { |(k, v), a| a[k] = v.clone }
        )
      end

      def primitive?
        false
      end

      def assign_parent(par)
        @parent = par
        struct_instance_variables.each do |attrname|
          send(attrname).assign_parent(self)
        end
      end

      def parent
        @parent if defined?(@parent)
      end

      def assign_model(model)
        @in_model = model unless is_a?(Model)
        struct_instance_variables.each do |attrname|
          send(attrname).assign_model(model)
        end
      end

      def in_model
        @in_model if defined?(@in_model)
      end

      def build_index(hash_index = {})
        hash_index[id] = self
        struct_instance_variables.reduce(hash_index) { |a, e| send(e).build_index(a) }
      end

      def diff(other)
        return [Diff::Delete.new(Archimate.node_reference(self))] if other.nil?
        raise TypeError, "Expected other <#{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
        struct_instance_variables.each_with_object([]) do |k, a|
          val = send(k)
          if val.nil?
            a.concat([DataModel::Insert.new(other, k)]) unless other.send(k).nil?
          elsif val.primitive?
            a.concat(val.diff(other.send(k), self, other, k))
          else
            a.concat(val.diff(other.send(k)))
          end
        end
      end

      def match(other)
        self == other
      end

      def ancestors
        result = [self]
        p = self
        result << p until (p = p.parent).nil?
        result
      end

      def path(options = {})
        [
          parent&.path(options),
          parent&.attribute_name(self, options)
        ].compact.map(&:to_s).reject(&:empty?).join("/")
      end

      def struct_instance_variables
        self.class.schema.keys
      end

      def compact
        struct_instance_variables.each { |attrname| send(attrname).compact }
        self
      end

      def attribute_name(v, _options = {})
        self.class.schema.keys.reduce do |a, e|
          a = e if v.equal?(send(e))
          a
        end
      end

      def delete(attrname, _value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{self.class.schema.keys.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        instance_variable_set("@#{attrname}".to_sym, nil)
        self
      end

      def insert(attrname, value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{self.class.schema.keys.map(&:to_s).join(',')}"
        ) if attrname.nil? #  || attrname.empty?
        instance_variable_set("@#{attrname}".to_sym, value)
        self
      end

      def change(attrname, _from_value, to_value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{self.class.schema.keys.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        instance_variable_set("@#{attrname}".to_sym, to_value)
        self
      end
    end
  end
end
