class Redis
  class Store < self
    include Interface

    def initialize(options = { })
      super
      _extend_marshalling options
      _extend_namespace   options
    end

    def to_s
      "Redis Client connected to #{@client.host}:#{@client.port} against DB #{@client.db}"
    end

    private
      def _extend_marshalling(options)
        @marshalling = !(options[:marshalling] === false) # HACK - TODO delegate to Factory
        extend ::Redis::Marshalling if @marshalling
      end

      def _extend_namespace(options)
        @namespace = options[:namespace]
        extend ::Redis::Namespace if @namespace
      end
  end
end
