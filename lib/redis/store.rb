class Redis
  class Store < self
    include Ttl, Interface

    STRATEGIES = {
      :marshal      => Strategy::Marshal,
      :json         => Strategy::Json,
      :json_session => Strategy::JsonSession,
      :yaml         => Strategy::Yaml,
    }.freeze

    def initialize(options = { })
      super
      _extend_strategy  options
      _extend_namespace options
    end

    def self.rails3? #:nodoc:
      defined?(::Rails) && ::Rails::VERSION::MAJOR == 3
    end

    def self.rails31? #:nodoc:
      defined?(::Rails) && ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 1
    end

    def reconnect
      @client.reconnect
    end

    def to_s
      "Redis Client connected to #{@client.host}:#{@client.port} against DB #{@client.db}"
    end

    private
      def _extend_strategy(options)
        strategy = options[:strategy]

        unless strategy === false
          strategy_class = STRATEGIES[strategy] || STRATEGIES[:marshal]
          extend Strategy, strategy_class
        end
      end

      def _extend_namespace(options)
        @namespace = options[:namespace]
        extend Namespace if @namespace
      end
  end
end

