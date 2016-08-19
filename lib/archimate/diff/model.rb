# frozen_string_literal: true
module Archimate
  module Diff
    class Model
      attr_reader :id, :name, :documentation, :properties

      def initialize(node)
        @id = node["id"]
        @name = node["name"]
        @documentation = Documentation.new(node.css(">purpose"))
        @properties = Properties.new(node.css(">property"))
      end
    end
  end
end
