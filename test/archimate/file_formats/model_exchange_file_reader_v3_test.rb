# frozen_string_literal: true
require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ModelExchangeFileReaderV3Test < Minitest::Test
      def test_archi_metal_read_write
        verify_read_write("ArchiMetal V3.xml")
      end

      def test_archisurance_read_write
        verify_read_write("ArchiSurance V3.xml")
      end

      def test_basic_model_read_write
        verify_read_write("Basic_Model.xml")
      end

      def test_basic_model_metadata_read_write
        verify_read_write("Basic_Model_Metadata.xml")
      end

      def test_basic_model_organization_read_write
        verify_read_write("Basic_Model_Organization.xml")
      end

      def test_basic_model_properties_read_write
        verify_read_write("Basic_Model_Properties.xml")
      end

      def test_model_view_read_write
        verify_read_write("Model_View.xml")
      end

      def verify_read_write(filename)
        test_file = File.join(TEST_EXAMPLES_FOLDER, filename)
        puts "Reading file #{test_file}"
        source = File.read(test_file)
        model = Archimate::FileFormats::ModelExchangeFileReader.parse(source)
        source.gsub!(" />", "/>")
        result_io = StringIO.new
        ModelExchangeFileWriter.write(model, result_io)
        assert_equal source, result_io.string
      end
    end
  end
end
