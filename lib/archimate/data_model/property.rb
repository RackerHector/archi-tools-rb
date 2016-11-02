# frozen_string_literal: true
module Archimate
  module DataModel
    class Property < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :key, Strict::String
      attribute :value, Strict::String.optional

      def comparison_attributes
        [:@key, :@value]
      end

      def self.create(options = {})
        new_opts = {
          value: nil
        }.merge(options)
        Property.new(new_opts)
      end

      def clone
        Property.new(
          parent_id: parent_id.clone,
          key: key.clone,
          value: value&.clone
        )
      end

      def to_s
        "Property(key: #{key}, value: #{value || 'no value'})"
      end
    end

    Dry::Types.register_class(Property)
    PropertiesList = Strict::Array.member(Property)
  end
end
