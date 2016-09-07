# frozen_string_literal: true
module Archimate
  module Model
    class Model
      attr_reader :id, :name, :documentation, :properties, :elements, :organization, :relationships

      def initialize(id, name, documentation = [], properties = [], elements = [], organization = [], relationships = [])
        @id = id
        @name = name
        @documentation = documentation
        @properties = properties
        @elements = elements
        @organization = organization
        @relationships = relationships
      end
    end
  end
end
