module Trailblazer
  module Container
    class Namespaced
      def initialize(container, ctx, namespace)
        @container = container
        @namespace = namespace
        @ctx       = ctx
      end

      def [](key)
        puts "@@@@@#key #{key.inspect}"
        namespaced_key = "#{@namespace}.#{key}"


# DISCUSS: do we want this prio check?
        @ctx[key] or @container.key?(namespaced_key) ? @container[namespaced_key] : @container[key] # FIXME: nil, etc
      end

      def to_hash
        @ctx.to_hash # we can't convert @container variables to kwargs anyway
      end

      def key?(key)
        namespaced_key = "#{@namespace}.#{key}" # FIXME: redundant

        @ctx.key?(key) || @container.key?(namespaced_key) || @container.key?(key) # FIXME: do we want this?
      end

      def []=(name, value)
        @ctx[name] = value
      end

      def merge(hash)
        # raise hash.inspect
        hash.each { |k,v| @ctx[k] = v }
        self
      end
    end # Namespaced
  end
end
