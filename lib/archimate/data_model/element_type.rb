# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module DataModel
    # Enumeration class that defines the strings used for all Archimate element
    # types.
    class ElementType
      include Ruby::Enum

      define :BusinessActor, "BusinessActor"
      define :BusinessCollaboration, "BusinessCollaboration"
      define :BusinessEvent, "BusinessEvent"
      define :BusinessFunction, "BusinessFunction"
      define :BusinessInteraction, "BusinessInteraction"
      define :BusinessInterface, "BusinessInterface"
      define :BusinessObject, "BusinessObject"
      define :BusinessProcess, "BusinessProcess"
      define :BusinessRole, "BusinessRole"
      define :BusinessService, "BusinessService"
      define :Contract, "Contract"
      define :Location, "Location"
      define :Meaning, "Meaning"
      define :Value, "Value"
      define :Product, "Product"
      define :Representation, "Representation"
      define :ApplicationCollaboration, "ApplicationCollaboration"
      define :ApplicationComponent, "ApplicationComponent"
      define :ApplicationFunction, "ApplicationFunction"
      define :ApplicationInteraction, "ApplicationInteraction"
      define :ApplicationInterface, "ApplicationInterface"
      define :ApplicationService, "ApplicationService"
      define :DataObject, "DataObject"
      define :Artifact, "Artifact"
      define :CommunicationPath, "CommunicationPath"
      define :Device, "Device"
      define :InfrastructureFunction, "InfrastructureFunction"
      define :InfrastructureInterface, "InfrastructureInterface"
      define :InfrastructureService, "InfrastructureService"
      define :Network, "Network"
      define :Node, "Node"
      define :SystemSoftware, "SystemSoftware"
      define :Assessment, "Assessment"
      define :Constraint, "Constraint"
      define :Driver, "Driver"
      define :Goal, "Goal"
      define :Principle, "Principle"
      define :Requirement, "Requirement"
      define :Stakeholder, "Stakeholder"
      define :Deliverable, "Deliverable"
      define :Gap, "Gap"
      define :Plateau, "Plateau"
      define :WorkPackage, "WorkPackage"
      define :AndJunction, "AndJunction"
      define :Junction, "Junction"
      define :OrJunction, "OrJunction"
      define :Capability, "Capability"
      define :CourseOfAction, "CourseOfAction"
      define :Resource, "Resource"
      define :ApplicationProcess, "ApplicationProcess"
      define :ApplicationEvent, "ApplicationEvent"
      define :TechnologyCollaboration, "TechnologyCollaboration"
      define :TechnologyInterface, "TechnologyInterface"
      define :Path, "Path"
      define :CommunicationNetwork, "CommunicationNetwork"
      define :TechnologyFunction, "TechnologyFunction"
      define :TechnologyProcess, "TechnologyProcess"
      define :TechnologyInteraction, "TechnologyInteraction"
      define :TechnologyEvent, "TechnologyEvent"
      define :TechnologyService, "TechnologyService"
      define :TechnologyObject, "TechnologyObject"
      define :Equipment, "Equipment"
      define :Facility, "Facility"
      define :DistributionNetwork, "DistributionNetwork"
      define :Material, "Material"
      define :Outcome, "Outcome"
      define :ImplementationEvent, "ImplementationEvent"
      # @todo Is grouping a valid element type?
      # define :Grouping, "Grouping"

      # Case equality operator. Used to determine if a value is a member of this enum
      #
      # @param other [String] string to test for enum membership.
      def self.===(other)
        values.include?(other)
      end
    end
  end
end
