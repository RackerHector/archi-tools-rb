# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class ArchiHandlerFactory
          def handler_for(name, attrs)
            case name
            when "model", "archimate:model"
              Model
            when "documentation", "purpose"
              Sax::PreservedLangString
            when "element"
              element_type = Hash[attrs]["xsi:type"].sub(/archimate:/, '')
              case element_type
              when ArchimateV2::Entity, ArchimateV2::Junction
                Element
              when ArchimateV2::Relationship
                Relationship
              when ArchimateV2::Diagram
                Diagram
              else
                raise "Unexpected element_type #{element_type}"
              end
            when "property"
              Property
            when "folder"
              Organization
            when "child"
              ViewNode
            when "bounds"
              Bounds
            when "sourceConnection"
              Connection
            when "bendpoint"
              Location
            when "content"
              Content
            else
              raise "Unhandled element name #{name}"
            end
          end
        end
      end
    end
  end
end
