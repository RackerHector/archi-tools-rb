# frozen_string_literal: true

require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileReader
      def initialize(doc)
        @string_or_io = doc
      end

      def parse
        handler_factory = Sax::Archi::ArchiHandlerFactory.new
        parser = Nokogiri::XML::SAX::Parser.new(Sax::Document.new(handler_factory))
        parser.parse(@string_or_io)
        parser.document.model
      end
    end
  end
end
