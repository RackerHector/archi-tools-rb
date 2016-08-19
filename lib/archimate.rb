# frozen_string_literal: true
require "archimate/version"
require "nokogiri"

module Archimate
  # The root path for YARD source libraries
  ROOT = File.expand_path(File.dirname(__FILE__))

  application_folder_xpath = "/archimate:model/folder[@type='application']"
  business_folder_xpath = "/archimate:model/folder[@type='business']"
  technology_folder_xpath = "/archimate:model/folder[@type='technology']"
  motivation_folder_xpath = "/archimate:model/folder[@type='motivation']"
  implementation_migration_folder_xpath = "/archimate:model/folder[@type='implementation_migration']"
  connectors_folder_xpath = "/archimate:model/folder[@type='connectors']"
  relations_folder_xpath = "/archimate:model/folder[@type='relations']"
  diagrams_folder_xpath = "/archimate:model/folder[@type='diagrams']"

  ELEMENT_TYPE_TO_PARENT_XPATH = {
    "archimate:BusinessActor" => business_folder_xpath,
    "archimate:BusinessCollaboration" => business_folder_xpath,
    "archimate:BusinessEvent" => business_folder_xpath,
    "archimate:BusinessFunction" => business_folder_xpath,
    "archimate:BusinessInteraction" => business_folder_xpath,
    "archimate:BusinessInterface" => business_folder_xpath,
    "archimate:BusinessObject" => business_folder_xpath,
    "archimate:BusinessProcess" => business_folder_xpath,
    "archimate:BusinessRole" => business_folder_xpath,
    "archimate:BusinessService" => business_folder_xpath,
    "archimate:Contract" => business_folder_xpath,
    "archimate:Location" => business_folder_xpath,
    "archimate:Meaning" => business_folder_xpath,
    "archimate:Value" => business_folder_xpath,
    "archimate:Product" => business_folder_xpath,
    "archimate:Representation" => business_folder_xpath,

    "archimate:ApplicationCollaboration" => application_folder_xpath,
    "archimate:ApplicationComponent" => application_folder_xpath,
    "archimate:ApplicationFunction" => application_folder_xpath,
    "archimate:ApplicationInteraction" => application_folder_xpath,
    "archimate:ApplicationInterface" => application_folder_xpath,
    "archimate:ApplicationService" => application_folder_xpath,
    "archimate:DataObject" => application_folder_xpath,

    "archimate:Artifact" => technology_folder_xpath,
    "archimate:CommunicationPath" => technology_folder_xpath,
    "archimate:Device" => technology_folder_xpath,
    "archimate:InfrastructureFunction" => technology_folder_xpath,
    "archimate:InfrastructureInterface" => technology_folder_xpath,
    "archimate:InfrastructureService" => technology_folder_xpath,
    "archimate:Network" => technology_folder_xpath,
    "archimate:Node" => technology_folder_xpath,
    "archimate:SystemSoftware" => technology_folder_xpath,

    "archimate:Assessment" => motivation_folder_xpath,
    "archimate:Constraint" => motivation_folder_xpath,
    "archimate:Driver" => motivation_folder_xpath,
    "archimate:Goal" => motivation_folder_xpath,
    "archimate:Principle" => motivation_folder_xpath,
    "archimate:Requirement" => motivation_folder_xpath,
    "archimate:Stakeholder" => motivation_folder_xpath,

    "archimate:Deliverable" => implementation_migration_folder_xpath,
    "archimate:Gap" => implementation_migration_folder_xpath,
    "archimate:Plateau" => implementation_migration_folder_xpath,
    "archimate:WorkPackage" => implementation_migration_folder_xpath,

    "archimate:AndJunction" => connectors_folder_xpath,
    "archimate:Junction" => connectors_folder_xpath,
    "archimate:OrJunction" => connectors_folder_xpath,

    "archimate:AccessRelationship" => relations_folder_xpath,
    "archimate:AggregationRelationship" => relations_folder_xpath,
    "archimate:AssignmentRelationship" => relations_folder_xpath,
    "archimate:AssociationRelationship" => relations_folder_xpath,
    "archimate:CompositionRelationship" => relations_folder_xpath,
    "archimate:FlowRelationship" => relations_folder_xpath,
    "archimate:InfluenceRelationship" => relations_folder_xpath,
    "archimate:RealisationRelationship" => relations_folder_xpath,
    "archimate:SpecialisationRelationship" => relations_folder_xpath,
    "archimate:TriggeringRelationship" => relations_folder_xpath,
    "archimate:UsedByRelationship" => relations_folder_xpath,

    "archimate:SketchModel" => diagrams_folder_xpath,
    "archimate:ArchimateDiagramModel" => diagrams_folder_xpath
  }.freeze

  require File.join(Archimate::ROOT, 'archimate', 'autoload')

  def self.new_xml_doc(xml_str = nil)
    Nokogiri::XML::Document.new(xml_str)
  end

  def self.parse_xml(xml_str)
    Nokogiri::XML(xml_str)
  end
end
