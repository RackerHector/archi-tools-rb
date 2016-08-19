# frozen_string_literal: true
require 'test_helper'
require 'pp'

module Archimate
  module Cli
    class ArchiTest < Minitest::Test
      def setup
        @archi = Archi.new
        @test_file = File.join(TEST_OUTPUT_FOLDER, "test.archimate")
        FileUtils.rm(@test_file) if File.exist?(@test_file)
      end

      def teardown
        FileUtils.rm(@test_file) if File.exist?(@test_file)
      end

      def test_map
        Archi.start(
          [
            "map",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file
          ]
        )
        # TODO: make this actually test something
      end

      def test_merge
        Archi.start(
          [
            "merge",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            File.join(TEST_EXAMPLES_FOLDER, 'merger_1_1.archimate'),
            "-o",
            @test_file
          ]
        )
        # TODO: make this actually test something
      end

      def test_svg
        Archi.start(["svg", File.join(TEST_EXAMPLES_FOLDER, 'base.archimate')])
        # TODO: make this actually test something
      end

      def test_dupes
        Archi.start(["dupes", File.join(TEST_EXAMPLES_FOLDER, 'base.archimate')])
        # TODO: make this actually test something
      end

      def test_clean
        Archi.start(
          [
            "clean",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-r",
            File.join(TEST_OUTPUT_FOLDER, "test_clean_removed.xml")
          ]
        )
        # TODO: make this actually test something
      end

      def test_dedupe
        Archi.start(
          [
            "dedupe",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-m",
            "-f"
          ]
        )
        # TODO: make this actually test something
      end

      def test_convert_meff
        Archi.start(
          [
            "convert",
            "-t",
            "meff2.1",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-f"
          ]
        )
        # TODO: make this actually test something
      end

      def test_convert_quads
        Archi.start(
          [
            "convert",
            "-t",
            "nquads",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-f"
          ]
        )
        # TODO: make this actually test something
      end
    end
  end
end
