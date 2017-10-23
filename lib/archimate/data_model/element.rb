# frozen_string_literal: true

module Archimate
  module DataModel
    # A base element type that can be extended by concrete ArchiMate types.
    #
    # Note that ElementType is abstract, so one must have derived types of this
    # type. This is indicated in xml by having a tag name of +element+ and an
    # attribute of +xsi:type="BusinessRole"+ where +BusinessRole+ is a derived
    # type from [ElementType].
    #
    # @todo Possible Make this abstract with concrete implementations for all
    #       valid element types
    class Element
      include Comparison

      # @!attribute [r] id
      #   @return [String]
      model_attr :id
      # @!attribute [r] name
      #   @return [LangString, NilClass]
      model_attr :name
      # @!attribute [rw] documentation
      #   @return [PreservedLangString, NilClass]
      model_attr :documentation, writable: true
      # # @return [Array<AnyElement>]
      # model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      # model_attr :other_attributes
      # @note type here was used for the Element/Relationship/Diagram type
      # @!attribute [r] type
      #   @return [String, NilClass]
      model_attr :type
      # @!attribute [r] properties
      #   @return [Array<Property>]
      model_attr :properties

      def initialize(id:, name:, documentation: nil, type: nil, properties: [])
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @properties = properties
      end

      def to_s
        Archimate::Color.layer_color(layer, "#{type}<#{id}>[#{name}]")
      end

      def layer
        Layers.for_element(type)
      end

      # Diagrams that this element is referenced in.
      # @todo this implementation is broken - in_model no longer exists
      def diagrams
        @diagrams ||= in_model.diagrams.select do |diagram|
          diagram.element_ids.include?(id)
        end
      end

      # Relationships that this element is referenced in.
      # @todo this implementation is broken - in_model no longer exists
      def relationships
        @relationships ||= in_model.relationships.select do |relationship|
          relationship.source == id || relationship.target == id
        end
      end

      # Copy any attributes/docs, etc. from each of the others into the original.
      #     1. Child `label`s with different `xml:lang` attribute values
      #     2. Child `documentation` (and different `xml:lang` attribute values)
      #     3. Child `properties`
      #     4. Any other elements
      # @todo this implementation is broken - in_model no longer exists
      def merge(element)
        super
        element.diagrams.each { |diagram| diagram.replace(element, self) }
        element.relationships.each { |relationship| relationship.replace(element, self) }
        element.organization.remove(element.id)
      end
    end
  end
end
