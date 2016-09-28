module Archimate
  module DataModel
    class Bounds < Dry::Struct::Value
      attribute :x, Coercible::Float.optional
      attribute :y, Coercible::Float.optional
      attribute :width, Coercible::Float
      attribute :height, Coercible::Float
    end
    Dry::Types.register_class(Bounds)
    OptionalBounds = Bounds.optional
  end
end
