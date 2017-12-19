# frozen_string_literal: true

module Archimate
  module Cli
    require "thor"

    def self.output_io(output_io, force)
      if output_io.is_a?(String)
        if !force && File.exist?(output_io)
          # TODO: This needs to be handled with more grace
          cli = HighLine.new
          return nil unless cli.agree("File #{output_io} exists. Overwrite?")
        end
        output_io = File.open(output_io, "w")
      end
      output_io
    end

    class Archi < Thor
      desc "stats ARCHIFILE", "Show some statistics about the model"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def stats(archifile)
        Config.instance.interactive = !options.fetch("noninteractive", false)
        Archimate::Cli::Stats.new(
          Archimate.read(archifile),
          $stdout
        ).statistics
      end

      desc "map ARCHIFILE", "Produce a map of diagram links to a diagram"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def map(archifile)
        Config.instance.interactive = !options.fetch("noninteractive", false)
        Archimate::Cli::Mapper.new(
          Archimate.read(archifile),
          Cli.output_io(options.fetch("output", $stdout), false)
        ).map
      end

      desc "svg -o OUTPUTDIR ARCHIFILE", "Produce semantically meaningful SVG files from an Archi file"
      option :output,
             aliases: :o,
             required: true,
             desc: "Write output to OUTPUTDIR"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def svg(archifile)
        Config.instance.interactive = !options.fetch("noninteractive", false)
        Archimate::Cli::Svger.export_svgs(
          archifile,
          options.fetch("output", Dir.pwd)
        )
      end

      desc "clean ARCHIFILE", "Clean up unreferenced elements and relations"
      option :output,
             aliases: :o,
             desc: "Write output to OUTPUT instead of replacing ARCHIFILE"
      option :saveremoved,
             aliases: :r,
             desc: "Write removed elements into SAVEREMOVED"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      option :force,
             aliases: :f,
             type: :boolean,
             default: false,
             desc: "Force overwriting of existing output file"
      def clean(archifile)
        Config.instance.interactive = !options.fetch("noninteractive", false)
        output_io = Cli.output_io(
          options.fetch("output", archifile),
          options.fetch("force", false)
        )
        Archimate::MaybeIO.new(options.fetch(:saveremoved, nil)) do |removed_element_io|
          Archimate::Cli::Cleanup.new(Archimate.read(archifile), output_io, removed_element_io).clean
        end
        output_io.close
      end

      desc "dupes ARCHIFILE", "List (potential) duplicate elements in Archi file"
      def dupes(archifile)
        Archimate::Cli::Duper.new(
          Archimate.read(archifile),
          $stdout
        ).list
      end

      desc "dedupe ARCHIFILE", "de-duplicate elements in Archi file"
      option :mergeall,
             aliases: :m,
             type: :boolean,
             default: false,
             desc: "Merges all duplicates without asking"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of replacing ARCHIFILE"
      option :force,
             aliases: :f,
             type: :boolean,
             default: false,
             desc: "Force overwriting of existing output file"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def dedupe(archifile)
        Config.instance.interactive = !options.fetch("noninteractive", false)
        output_io = Cli.output_io(
          options.fetch("output", archifile),
          options[:force]
        )
        Archimate::Cli::Duper.new(
          Archimate.read(archifile),
          output_io,
          options[:mergeall]
        ).merge
        output_io.close
      end

      desc "convert ARCHIFILE", "Convert the incoming file to the desired type"
      long_desc <<~CONVERT_DESC
        Converts the input ArchiMate file into another format. Options are:
        \x5  • 'archi'   for Archi file format (http://archimatetool.com),
        \x5  • 'meff2.1' for Open Group Model Exchange File Format for ArchiMate 2.1,
        \x5  • 'nquads'  for RDF 1.1 N-Quads format https://www.w3.org/TR/n-quads/,
        \x5  • 'graphml' for GraphML,
        \x5  • 'csv'     for CSV files (one file per element/relationship type)
      CONVERT_DESC
      option :to,
             aliases: :t,
             default: Archimate::Cli::Convert::SUPPORTED_FORMATS.first,
             enum: Archimate::Cli::Convert::SUPPORTED_FORMATS,
             desc: "Output format to convert to"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      option :outputdir,
             aliases: :d,
             desc: "Write output to DIRECTORY."
      option :force,
             aliases: :f,
             type: :boolean,
             desc: "Force overwriting of existing output file"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def convert(archifile)
        output_dir = options.fetch("outputdir", Dir.pwd)
        output_io = Cli.output_io(
          options.fetch("output", $stdout),
          options.fetch("force", false)
        )
        Config.instance.interactive = !options.fetch("noninteractive", false)
        Archimate::Cli::Convert.new(
          Archimate.read(archifile)
        ).convert(options[:to], output_io, output_dir)
      end

      desc "lint ARCHIFILE", "Examine the ArchiMate file for potential problems"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of STDOUT"
      def lint(archifile)
        output_io = Cli.output_io(
          options.fetch("output", $stdout),
          options.fetch("force", false)
        )
        Archimate::Cli::Lint.new(
          Archimate.read(archifile),
          output_io
        ).lint
      end
    end
  end
end
