# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      class LangString < FileFormats::Sax::Handler
        include Sax::CaptureContent

        def initialize(name, attrs, parent_handler)
          super
        end

        def complete
          doc = DataModel::LangString.string(
            process_text(content),
            @attrs["lang"] || @attrs["xml:lang"]
          )
          [
            event(
              :on_lang_string,
              doc
            )
          ]
        end
      end
    end
  end
end
