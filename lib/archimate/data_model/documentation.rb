# frozen_string_literal: true
module Archimate
  module DataModel
    class Documentation < Dry::Struct
      include With
      include DiffableStruct

      constructor_type :schema

      attribute :lang, Strict::String.default("en")
      attribute :text, Strict::String

      def to_s
        "Documentation<#{object_id}>[#{[lang, text].compact.join(',')}]"
      end
    end

    Dry::Types.register_class(Documentation)
    DocumentationList = Strict::Array.member(Documentation).default([])
  end
end
