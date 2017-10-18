# frozen_string_literal: true

module Archimate
  module DataModel
    class Diagram
      include Comparison

      # @!attribute [r] id
      #   @return [String]
      model_attr :id
      # @!attribute [rw] name
      #   @return [LangString]
      model_attr :name, writable: true
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
      # @!attribute [rw] properties
      #   @return [Array<Property>]
      model_attr :properties, writable: true
      # @todo make this a ViewpointType is better but is Archimate specification version dependent
      # @!attribute [r] viewpoint_type
      #   @return [String, NilClass]
      model_attr :viewpoint_type
      # @!attribute [r] viewpoint
      #   @return [Viewpoint, NilClass]
      model_attr :viewpoint
      # @!attribute [rw] nodes
      #   @return [Array<ViewNode>]
      model_attr :nodes, writable: true
      # @todo Archi formats only fill this in, should be an enum
      # @!attribute [r] connection_router_type
      #   @return [Int, NilClass]
      model_attr :connection_router_type
      # value of 0 on Archi Sketch Model
      # @!attribute [r] background
      #   @return [Int, NilClass]
      model_attr :background
      # @!attribute [rw] connections
      #   @return [Array<Connection>]
      model_attr :connections, writable: true

      def initialize(id:, name:, documentation: nil, type: nil, properties: [],
                     viewpoint_type: nil, viewpoint: nil, nodes: [],
                     connection_router_type: nil, background: nil, connections: [])
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @properties = properties
        @viewpoint_type = viewpoint_type
        @viewpoint = viewpoint
        @nodes = nodes
        @connection_router_type = connection_router_type
        @background = background
        @connections = connections
      end

      def all_nodes
        nodes.inject(Array.new(nodes)) { |child_ary, child| child_ary.concat(child.all_nodes) }
      end

      def elements
        @elements ||= all_nodes.map(&:element).compact
      end

      def element_ids
        @element_ids ||= elements.map(&:id)
      end

      def relationships
        @relationships ||= connections.map(&:relationship).compact
      end

      def relationship_ids
        @relationship_ids ||= relationships.map(&:id)
      end

      def to_s
        "#{Archimate::Color.data_model('Diagram')}<#{id}>[#{Archimate::Color.color(name, %i[white underline])}]"
      end

      def total_viewpoint?
        viewpoint_type.nil? || viewpoint_type.empty?
      end

      def referenced_identified_nodes
        (nodes + connections)
          .map(&:referenced_identified_nodes)
          .flatten
          .uniq
      end
    end
  end
end
