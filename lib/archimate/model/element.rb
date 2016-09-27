# frozen_string_literal: true
module Archimate
  module Model
    class Element < Dry::Struct::Value
      attribute :id, Types::Strict::String
      attribute :type, Types::Strict::String.optional
      attribute :label, Types::Strict::String.optional
      attribute :documentation, Types::DocumentationList
      attribute :properties, Types::PropertiesList

      alias name label

      def self.create(options = {})
        new_opts = {
          type: nil,
          label: nil,
          documentation: [],
          properties: []
        }.merge(options)
        Element.new(new_opts)
      end

      def with(options = {})
        Element.new(to_h.merge(options))
      end

      def to_s
        "#{type}<#{id}> #{label} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def short_desc
        "#{type}<#{id}> #{label}"
      end

      def to_id_string
        "#{type}<#{id}>"
      end

      def layer
        Archimate::Constants::ELEMENT_LAYER.fetch(@type, "None")
      end
    end
  end
end
