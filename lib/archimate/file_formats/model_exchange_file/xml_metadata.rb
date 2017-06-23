# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class XmlMetadata
        def initialize(metadata)
          @metadata = metadata
        end

        def serialize(xml)
          return unless @metadata && @metadata.schema_infos.size > 0
          xml.metadata do
            if @metadata.schema_infos.size == 1
              serialize_schema_info_body(xml, @metadata.schema_infos.first)
            else
              @metadata.schema_infos.each do |schema_info|
                serialize_schema_info(xml, schema_info)
              end
            end
          end
        end

        private

        def serialize_schema_info(xml, schema_info)
          xml.schemaInfo do
            serialize_schema_info_body(xml, schema_info)
          end
        end

        def serialize_schema_info_body(xml, schema_info)
          xml.schema { xml.text (schema_info.schema) } if schema_info.schema
          xml.schemaversion { xml.text (schema_info.schemaversion) } if schema_info.schemaversion
          schema_info.elements.each do |el|
            serialize_any_element(xml, el)
          end
        end

        def serialize_any_element(xml, el)
          if el.prefix && !el.prefix.empty?
            xml_prefix = xml[el.prefix]
          else
            xml_prefix = xml
          end
          xml_prefix.send(el.element.to_sym, serialize_any_attributes(el.attributes)) do
            xml.text(el.content) if el.content&.size > 0
            el.children.each { |child| serialize_any_element(xml, child) }
          end
        end

        def serialize_any_attributes(attrs)
          attrs.each_with_object({}) do |attr, hash|
            key = attr.prefix&.size > 0 ? [attr.prefix, attr.attribute].join(":") : attr.attribute
            hash[key] = attr.value
          end
        end
      end
    end
  end
end
