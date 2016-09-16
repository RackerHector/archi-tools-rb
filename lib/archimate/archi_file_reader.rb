# frozen_string_literal: true
module Archimate
  class ArchiFileReader
    def self.read(archifile)
      reader = new
      reader.read(archifile)
    end

    def read(archifile)
      parse(Nokogiri::XML(File.read(archifile)))
    end

    def parse(doc)
      Model::Model.new(
        doc.root["id"],
        doc.root["name"]
      ) do |model|
        model.documentation = parse_documentation(doc.root, "purpose")
        model.properties = parse_properties(doc.root)
        model.elements = parse_elements(doc.root)
        model.organization = parse_organization(doc.root)
        model.relationships = parse_relationships(doc.root)
        model.diagrams = parse_diagrams(doc.root)
      end
    end

    def parse_documentation(node, element_name = "documentation")
      node.css(">#{element_name}").each_with_object([]) { |i, a| a << i.content.strip }
    end

    def parse_properties(node)
      node.css(">property").each_with_object([]) { |i, a| a << Model::Property.new(i["key"], i["value"]) }
    end

    def parse_elements(model)
      model.css(Conversion::ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').each_with_object({}) do |i, a|
        a[i["id"]] = parse_element(i)
      end
    end

    def parse_element(node)
      Model::Element.new(
        node["id"],
        node["name"],
        node["xsi:type"].sub("archimate:", ""),
        parse_documentation(node),
        parse_properties(node)
      )
    end

    def parse_organization(model)
      Model::Organization.new(parse_folders(model))
    end

    def parse_folders(node)
      node.css("> folder").each_with_object([]) { |i, a| a << parse_folder(i) }
    end

    def parse_folder(node)
      Model::Folder.new(node.attr("id"), node.attr("name"), node.attr("type")) do |folder|
        folder.documentation = parse_documentation(node)
        folder.properties = parse_properties(node)
        folder.items = child_element_ids(node)
        folder.folders = parse_folders(node)
      end
    end

    def child_element_ids(node)
      []
    end

    def parse_relationships(model)
      model.css(Conversion::ArchiFileFormat::RELATION_XPATHS.join(",")).css("element").each_with_object({}) do |i, a|
        a[i["id"]] = Model::Relationship.new(
          i["id"],
          i.attr("xsi:type").sub("archimate:", ""),
          i.attr("source"),
          i.attr("target"),
          i["name"]
        ) do |rel|
          rel.documentation = parse_documentation(i)
          rel.properties = parse_properties(i)
        end
      end
    end

    def parse_diagrams(model)
      model.css(Conversion::ArchiFileFormat::DIAGRAM_XPATHS.join(",")).css(
        'element[xsi|type="archimate:ArchimateDiagramModel"]'
      ).each_with_object({}) do |i, a|
        a[i["id"]] = Model::Diagram.new(i["id"], i["name"]) do |dia|
          dia.documentation = parse_documentation(i)
          dia.properties = parse_properties(i)
          dia.children = parse_children(i)
          # TODO: This is a quick fix to permit diff/merge
          dia.element_references = model.css(
            "folder[type=\"diagrams\"] [archimateElement]"
          ).each_with_object([]) { |i2, a2| a2 << i2.attr("archimateElement") }
        end
      end
    end

    def parse_children(node)
      node.css("> child").each_with_object([]) do |i, a|
        a << parse_child(i)
      end
    end

    def parse_child(child_node)
      Model::Child.new(child_node["id"]) do |child|
        [
          [:type=, "xsi:type"],
          [:text_alignment=, "textAlignment"],
          [:fill_color=, "fillColor"],
          [:model=, "model"],
          [:name=, "name"],
          [:target_connections=, "targetConnections"],
          [:archimate_element=, "archimateElement"],
          [:font=, "font"],
          [:line_color=, "lineColor"],
          [:font_color=, "fontColor"]
        ].each do |attr_setter, attr_name|
          child.send(attr_setter, child_node.attr(attr_name)) if child_node.attributes.include?(attr_name)
        end

        child.bounds = parse_bounds(child_node.at_css("> bounds"))
        child.children = parse_children(child_node)
        child.source_connection = parse_source_connections(child_node.css("> sourceConnection"))
        child
      end
    end

    def parse_bounds(node)
      Model::Bounds.new(node.attr("x"), node.attr("y"), node.attr("width"), node.attr("height"))
    end

    def parse_source_connections(nodes)
      nodes.each_with_object([]) do |i, a|
        a << Model::SourceConnection.new(i["id"]) do |sc|
          [
            [:type=, "xsi:type"],
            [:source=, "source"],
            [:target=, "target"],
            [:relationship=, "relationship"]
          ].each do |attr_setter, attr_name|
            sc.send(attr_setter, i.attr(attr_name)) if i.attributes.include?(attr_name)
          end

          sc.bendpoints = parse_bendpoints(i.css("bendpoint"))
        end
      end
    end

    def parse_bendpoints(nodes)
      nodes.each_with_object([]) do |i, a|
        a << Model::Bendpoint.new(i.attr("startX"), i.attr("startY"), i.attr("endX"), i.attr("endY"))
      end
    end
  end
end
