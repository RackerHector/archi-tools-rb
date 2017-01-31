# frozen_string_literal: true
module Archimate
  module Cli
    class Svger
      def self.export_svgs(archi_file, aio)
        new(Archimate.read(archi_file, aio), aio).export_svgs
      end

      def initialize(model, aio)
        @model = model
        @aio = aio
      end

      def export_svgs
        Svg::Export.new(@model, @aio).export_all
      end
    end
  end
end
