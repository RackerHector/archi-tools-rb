# frozen_string_literal: true
module Archimate
  module DataModel
    class Child < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :id, Strict::String
      attribute :type, Strict::String.optional
      attribute :model, Strict::String.optional
      attribute :name, Strict::String.optional
      attribute :content, Strict::String.optional
      attribute :target_connections, Strict::String.optional # TODO: this is a list encoded in a string
      attribute :archimate_element, Strict::String.optional
      attribute :bounds, OptionalBounds
      attribute :children, Strict::Array.member(Child)
      attribute :source_connections, SourceConnectionList
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :style, OptionalStyle
      attribute :child_type, Coercible::Int.optional

      def self.create(options = {})
        new_opts = {
          type: nil,
          model: nil,
          name: nil,
          content: nil,
          target_connections: nil,
          archimate_element: nil,
          bounds: nil,
          children: [],
          source_connections: [],
          documentation: [],
          properties: [],
          style: nil,
          child_type: nil
        }.merge(options)
        Child.new(new_opts)
      end

      def comparison_attributes
        [
          :@id, :@type, :@model, :@name, :@content, :@target_connections,
          :@archimate_element, :@bounds, :@children, :@source_connections,
          :@documentation, :@properties, :@style, :@child_type
        ]
      end

      def clone
        Child.new(
          parent_id: parent_id.clone,
          id: id.clone,
          type: type&.clone,
          model: model&.clone,
          name: name&.clone,
          content: content&.clone,
          target_connections: target_connections&.clone,
          archimate_element: archimate_element&.clone,
          bounds: bounds&.clone,
          children: children.map(&:clone),
          source_connections: source_connections.map(&:clone),
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          style: style&.clone,
          child_type: child_type
        )
      end

      def element_references
        children.each_with_object([archimate_element]) do |i, a|
          a.concat(i.element_references)
        end
      end

      def relationships
        children.each_with_object(source_connections.map(&:relationship).compact) do |i, a|
          a.concat(i.relationships)
        end
      end

      def to_s
        "Child[#{name || ''}](#{in_model.lookup(archimate_element) if archimate_element && in_model})"
      end
    end

    Dry::Types.register_class(Child)
  end
end

# Type is one of:  ["archimate:DiagramModelReference", "archimate:Group", "archimate:DiagramObject"]
# textAlignment "2"
# model is on only type of archimate:DiagramModelReference and is id of another element type=archimate:ArchimateDiagramModel
# fillColor, lineColor, fontColor are web hex colors
# targetConnections is a string of space separated ids to connections on diagram objects found on DiagramObject
# archimateElement is an id of a model element found on DiagramObject types
# font is of this form: font="1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial"
