# frozen_string_literal: true
module Archimate
  module Model
    class Element
      attr_accessor :id, :type, :label, :documentation, :properties

      alias name label

      def initialize(id = "", label = "", type = "", documentation = [], properties = [])
        @id = id
        @label = label
        @type = type
        @documentation = documentation
        @properties = properties
        yield self if block_given?
      end

      def ==(other)
        @id == other.id &&
          @label == other.label &&
          @type == other.type &&
          @documentation == other.documentation &&
          @properties == other.properties
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
        case @type
        when "archimate:BusinessActor", "archimate:BusinessCollaboration",
             "archimate:BusinessEvent", "archimate:BusinessFunction",
             "archimate:BusinessInteraction", "archimate:BusinessInterface",
             "archimate:BusinessObject", "archimate:BusinessProcess",
             "archimate:BusinessRole", "archimate:BusinessService",
             "archimate:Contract", "archimate:Location",
             "archimate:Meaning", "archimate:Value",
             "archimate:Product", "archimate:Representation"
          then "Business"
        when "archimate:ApplicationCollaboration", "archimate:ApplicationComponent",
             "archimate:ApplicationFunction", "archimate:ApplicationInteraction",
             "archimate:ApplicationInterface", "archimate:ApplicationService",
             "archimate:DataObject"
          then "Application"
        when "archimate:Artifact", "archimate:CommunicationPath",
             "archimate:Device", "archimate:InfrastructureFunction",
             "archimate:InfrastructureInterface", "archimate:InfrastructureService",
             "archimate:Network", "archimate:Node", "archimate:SystemSoftware"
          then "Technology"
        when "archimate:Assessment", "archimate:Constraint", "archimate:Driver",
             "archimate:Goal", "archimate:Principle", "archimate:Requirement",
             "archimate:Stakeholder"
          then "Motivation"
        when "archimate:Deliverable", "archimate:Gap", "archimate:Plateau",
             "archimate:WorkPackage"
          then "Implementation and Migration"
        when "archimate:AndJunction", "archimate:Junction", "archimate:OrJunction"
          then "Connectors"
        else
          "None"
        end
      end
    end
  end
end
