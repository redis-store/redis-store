module Merb
  # HACK for cyclic dependency: redis-store is required before Merb session stores
  class Mash < Hash; end
  class SessionContainer < Mash; class_inheritable_accessor :session_store_type end
  class SessionStoreContainer < SessionContainer; end

  class RedisSession < SessionStoreContainer
    self.session_store_type = :redis
  end

  module RedisStore
    def retrieve_session(session_id)
      get("session:#{session_id}")
    end

    def store_session(session_id, data)
      set("session:#{session_id}", data)
    end

    def delete_session(session_id)
      delete("session:#{session_id}")
    end    
  end
end

module Rack
  module Session
    class Redis
      include Merb::RedisStore
    end
  end
end
