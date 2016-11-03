# frozen_string_literal: true
module Archimate
  module DataModel
    module With
      def with(options = {})
        self.class.new(to_h.merge(options))
      end

      def parent
        in_model&.lookup(parent_id)
      end

      def in_model
        instance_variable_get(:@in_model)
      end

      def assign_model(model)
        instance_variable_set(:@in_model, model)
        comparison_attributes.each do |attr|
          val = instance_variable_get(attr)
          case val
          when Dry::Struct
            val.assign_model(model)
          when Array
            val.each { |i| i.assign_model(model) if i.is_a?(Dry::Struct) }
          when Hash
            val.values.each { |i| i.assign_model(model) if i.is_a?(Dry::Struct) }
          end
        end
      end
    end
  end
end
