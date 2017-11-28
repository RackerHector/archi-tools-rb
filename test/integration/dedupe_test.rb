# frozen_string_literal: true

require 'test_helper'
require "test_examples"

module Archimate
  class DedupeTest < Minitest::Test
    def test_referenceable
      archisurance_model.relationships.each do |rel|
        assert(rel.source.references.include?(rel))
        assert(rel.target.references.include?(rel))
      end
    end

    def test_dedupe_archi_format
      Dir.mktmpdir do |dir|
        deduped_file = File.join(dir, "deduped.archimate")
        _out, err = capture_io do
          Cli::Archi.start ["dedupe", "-m", "-o", deduped_file, "test/examples/archisurance.archimate"]
        end

        src = File.read(deduped_file)
        lines = src.split("\n")
        %w[1536 1059 1101 1004 90702769].each do |id|
          refute_match "\"#{id}\"", lines.select { |line| line =~ /"#{id}"/ }.join("\n")
        end
        assert_empty err
        model = Archimate.parse(src)
        assert_equal(
          1,
          model.elements.select do |el|
            el.is_a?(DataModel::Elements::BusinessInterface) && el.name.to_s == "phone"
          end.size
        )
        # BusinessInterface has potential duplicates: <1540>[phone], <1536>[phone]
        assert(model.elements.none? { |el| el.id == "1536" })
        # Device has potential duplicates: <1053>[Unix Server], <1059>[Unix Server]
        assert_equal 1, model.elements.select { |el| el.is_a?(DataModel::Elements::Device) && el.name.to_s == "Unix Server" }.size
        assert(model.elements.none? { |el| el.id == "1059" })
        # Network has potential duplicates: <1089>[LAN], <1101>[LAN]
        assert(model.elements.none? { |el| el.id == "1101" })
        assert_equal 1, model.elements.select { |el| el.is_a?(DataModel::Elements::Network) && el.name.to_s == "LAN" }.size
        # Node has potential duplicates: <998>[Firewall], <1004>[Firewall]
        assert_equal 1, model.elements.select { |el| el.is_a?(DataModel::Elements::Node) && el.name.to_s == "Firewall" }.size
        assert(model.elements.none? { |el| el.id == "1004" })
        # Access has potential duplicates: <712>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File],
        #                                  <90702769>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File]
        assert_equal 1, model.relationships.select { |el| el.is_a?(DataModel::Relationships::Access) && el.name.to_s == "update" }.size
        assert(model.elements.none? { |el| el.id == "90702769" })
      end
    end

    def test_dedupe_archi_format_variations
      Dir.mktmpdir do |tmpdir|
        outfile = File.join(tmpdir, "deduped.archimate")
        out, err = capture_io do
          Cli::Archi.start ["dedupe", "-m", "-o", outfile, "--force", "test/examples/duplication.archimate"]
        end
        assert_empty err
        assert_empty out

        model = Archimate.read(outfile)
        assert_equal 1, model.application_components.size
        assert_equal "Application Component", model.application_components.first.name.to_s
        assert_equal 1, model.application_interfaces.size
        assert_equal "Application Interface", model.application_interfaces.first.name.to_s
        assert_equal 1, model.application_services.size
        assert_equal "Application Service", model.application_services.first.name.to_s
        assert_equal 1, model.application_functions.size
        assert_equal "Application Function", model.application_functions.first.name.to_s
        assert_equal 1, model.relationships.size
      end
    end
  end
end
