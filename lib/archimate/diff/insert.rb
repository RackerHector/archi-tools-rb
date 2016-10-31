# frozen_string_literal: true
module Archimate
  module Diff
    class Insert < Difference
      attr_accessor :inserted
      attr_accessor :to_model

      alias to inserted
      alias model to_model

      def initialize(path, to_model, inserted)
        super(path)
        @inserted = inserted
        @to_model = to_model
      end

      def ==(other)
        super &&
          other.is_a?(Insert) &&
          inserted == other.inserted
      end

      def to_s
        "#{'INSERT:'.green} #{path}: #{describe}"
      end

      def describe
        parent, remaining_path = describeable_parent(to_model)
        s = parent.describe(to_model)
        s += " #{remaining_path.light_blue} #{inserted.to_s.light_green}" unless remaining_path.empty?
        s
      end
    end
  end
end
