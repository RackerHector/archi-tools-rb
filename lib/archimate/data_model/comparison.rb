# frozen_string_literal: true

module Archimate
  module DataModel
    module Comparison
      def initialize(opts = {})
        self.class.attr_info.each do |sym, attr_info|
          if attr_info.default == :value_required && !opts.include?(sym)
            raise "#{self.class} required value for #{sym} is missing."
          end
          val = opts.fetch(sym, attr_info.default)
          instance_variable_set("@#{sym}".to_sym, val)
          val.add_reference(self) if val.is_a?(Referenceable)
        end

        self.class.attr_info.each do |sym, attr_info|
          if attr_info.referenceable_list
            instance_variable_set(
              "@#{sym}".to_sym,
              ReferenceableList.new(self, opts.fetch(sym, attr_info.default), attr_info.also_reference)
            )
          elsif attr_info.also_reference.size.positive?
            val = instance_variable_get("@#{sym}".to_sym)
            attr_info.also_reference.each do |ref_sym|
              ref = send(ref_sym)
              val.add_reference(ref) if ref && val
            end
          end
        end
      end

      def hash
        @hash_key ||=
          self.class.attr_names.reduce(self.class.hash) { |ha, attr| ha ^ send(attr).hash }
      end

      def ==(other)
        return true if equal?(other)
        other.is_a?(self.class) &&
          self.class.comparison_attr_paths.all? do |attr|
            dig(*attr) == other.dig(*attr)
          end
      end

      def [](sym)
        send(sym)
      end

      def dig(*args)
        return self if args.empty?
        val = send(args.shift)
        return val if args.empty?
        val&.dig(*args)
      end

      def to_h
        self.class.attr_names.each_with_object({}) { |i, a| a[i] = send(i) }
      end

      def each(&blk)
        self.class.comparison_attr_paths.each(&blk)
      end

      # @todo implement pretty_print as a more normal pretty_print with correct
      #       handling for attr_info values for comparison_attr
      def pretty_print(pp)
        pp.object_address_group(self) do
          pp.seplist(self.class.comparison_attr_paths, proc { pp.text ',' }) do |attr|
            column_value = dig(*attr)
            pp.breakable ' '
            pp.group(1) do
              pp.text Array(attr).map(&:to_s).join(".")
              pp.text ':'
              pp.breakable
              pp.pp column_value
            end
          end
        end
      end

      # @todo implement inspect as a more normal inspect with correct handling for
      #       attr_info values for comparison_attr
      def inspect
        "#<#{self.class.to_s.split('::').last}\n    " +
          self.class.attr_info
              .map { |sym, info| info.attr_inspect(self, sym) }
          .compact
              .join("\n    ") + "\n    >"
      end

      def brief_inspect
        "#<#{self.class.to_s.split('::').last}#{" id=#{id}" if respond_to?(:id)}#{" #{name.brief_inspect}" if respond_to?(:name) && name}>"
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        AttributeInfo = Struct.new(:comparison_attr, :writable, :default, :referenceable_list, :also_reference) do
          def attr_inspect(obj, sym)
            case comparison_attr
            when :no_compare
              nil
            when nil
              "#{sym}: #{attr_value_inspect(obj.send(sym))}"
            else
              val = obj.send(sym)
              cval = val&.send(comparison_attr)
              "#{sym}: #<#{val.class.to_s.split('::').last} #{comparison_attr}=#{attr_value_inspect(cval)}>"
            end
          end

          def attr_value_inspect(val)
            case val
            when Comparison
              val.brief_inspect
            when Array
              vals = val.first(3).map do |v|
                if v.is_a?(Comparison)
                  v.brief_inspect
                else
                  v.inspect
                end
              end
              "[#{vals.join(', ')}#{"...#{val.size}" if val.size > 3}]"
            else
              val.inspect
            end
          end
        end

        # Define the reader method (or call model_attr)
        # Append the attr_sym to the @@attrs for the class
        def model_attr(attr_sym, comparison_attr: nil, writable: false,
                       default: :value_required, referenceable_list: false,
                       also_reference: [])
          send(:attr_reader, attr_sym)
          attrs = attr_names << attr_sym
          class_variable_set(:@@attr_names, attrs.uniq)
          class_variable_set(
            :@@attr_info,
            attr_info.merge(attr_sym => AttributeInfo.new(
              comparison_attr, writable, default, referenceable_list, also_reference
            ))
          )
          if comparison_attr != :no_compare
            attrs = comparison_attr_paths << (comparison_attr ? [attr_sym, comparison_attr] : attr_sym)
            class_variable_set(:@@comparison_attr_paths, attrs.uniq)
          end
          return unless writable
          define_method("#{attr_sym}=".to_sym) do |val|
            instance_variable_set(:@hash_key, nil)
            old_val = instance_variable_get("@#{attr_sym}")
            if old_val.is_a?(ReferenceableList)
              old_val.replace_with(val)
            else
              old_val.remove_reference(self) if old_val.is_a?(Referenceable)
              instance_variable_set("@#{attr_sym}".to_sym, val)
              val.add_reference(self) if val.is_a?(Referenceable)
              also_reference.each do |ref_sym|
                ref = send(ref_sym)
                val.add_reference(ref) if ref && val
              end
            end
          end
        end

        def attr_names
          class_variable_defined?(:@@attr_names) ? class_variable_get(:@@attr_names) : []
        end

        def attr_info
          class_variable_defined?(:@@attr_info) ? class_variable_get(:@@attr_info) : {}
        end

        def comparison_attr_paths
          class_variable_defined?(:@@comparison_attr_paths) ? class_variable_get(:@@comparison_attr_paths) : []
        end
      end
    end
  end
end
