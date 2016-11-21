# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class SourceConnectionTest < Minitest::Test
      attr_reader :subject

      def setup
        @src_el = build_element
        @target_el = build_element
        @rel = build_relationship(source: @src_el.id, target: @src_el.id)
        @subject = build_source_connection(
          id: "abc123",
          type: "three",
          name: "test_name",
          source: "source",
          target: "target",
          relationship: "complicated"
        )
        @model = build_model(
          elements: [@src_el, @target_el],
          relationships: [@rel],
          diagrams: [
            build_diagram(
              children: [
                build_child(
                  source_connections: [@subject]
                )
              ]
            )
          ]
        )
      end

      def test_create
        assert_equal "abc123", subject.id
        assert_equal "three", subject.type
        refute_respond_to subject, :type=
      end

      def test_to_s
        assert_match("SourceConnection", subject.to_s)
        assert_match("[#{subject.name}]", HighLine.uncolor(subject.to_s))
      end
    end
  end
end
