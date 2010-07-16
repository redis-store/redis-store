class Redis
  module Namespace
    def marshalled_set(key, val, options = nil)
      namespace(key) { |key| super }
    end

    def marshalled_setnx(key, val, options = nil)
      namespace(key) { |key| super }
    end

    def marshalled_get(key, options = nil)
      namespace(key) { |key| super }
    end

    private
      def namespace(key)
        yield "#{@namespace}:#{key}"
      end
  end
end
