# frozen_string_literal: true
module Archimate
  module DataModel
    class SourceConnection < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String.optional
      attribute :id, Strict::String
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :relationship, Strict::String.optional
      attribute :name, Strict::String.optional
      attribute :type, Strict::String.optional
      attribute :bendpoints, BendpointList
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :style, OptionalStyle

      def comparison_attributes
        [:@id, :@source, :@target, :@relationship, :@name, :@type, :@bendpoints, :@documentation, :@properties, :@style]
      end

      def self.create(options = {})
        new_opts = {
          parent_id: nil,
          relationship: nil,
          name: nil,
          bendpoints: [],
          documentation: [],
          properties: [],
          style: nil,
          type: nil

        }.merge(options)
        SourceConnection.new(new_opts)
      end

      def clone
        SourceConnection.new(
          parent_id: parent_id&.clone,
          id: id.clone,
          source: source.clone,
          target: target.clone,
          relationship: relationship&.clone,
          name: name&.clone,
          type: type&.clone,
          bendpoints: bendpoints.map(&:clone),
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          style: style&.clone
        )
      end

      def type_name
        "#{'SourceConnection'.blue.italic}[#{(name || '').black.underline}]".on_light_magenta
      end

      def describe(model, options = {})
        s = model.elements[source]
        t = model.elements[target]
        "#{type_name} #{s.nil? ? 'nothing' : s.short_desc}->#{t.nil? ? 'nothing' : t.short_desc}"
      end
    end
    Dry::Types.register_class(SourceConnection)
    SourceConnectionList = Strict::Array.member("archimate.data_model.source_connection")
  end
end
