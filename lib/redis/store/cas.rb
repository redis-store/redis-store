class Redis
  class Store < self

    # Implements Compare-And-Swap (or as Redis says Compare-And-Save)
    # on top of Redis::Store using Redis::Store::watch. It is designated for simple values, not redis-lists/hashes etc
    # See https://redis.io/topics/transactions#cas
    module Cas

      # Single CAS
      #
      # Trys to save change the value of a redis-key when it may not done in a atomic matter. Eg, you have do some
      # checks on old value before setting the new one and so on. If key content changes meanwhile it refuses to
      # set and you will not overwrite changes from other Thread or Process.
      #
      # This method works only on existing keys in redis.
      # It works only with keys holding a value, eg, read/writeable with get/set
      #
      # @yield [value] the current value of given key
      # @yieldparam [String] key the key to get and set the value
      # @yieldreturn [String] the new value to store in key
      # @return [Boolean] true if new value was stored, otherwise false
      # @param key [String] the key to set. Must not be nil and key must exists in Redis
      # @param ttl [Integer] if not nil and integer > 0 set a TTL to the changed key
      # @example
      #
      #  storewithcas.cas('examplekey') do |value|
      #    # value is the CURRENT value!
      #    new_value = do_some_important_stuff_here(value)
      #    new_value # write back to redis unless key has changed meanwhile
      #  end
      def cas(key, ttl=nil)
        return false unless exists(key)
        watch(key) do
          value = get(key)
          value = yield value
          ires = multi do |multi|
            multi.set(key,value,ttl.nil? ? {} : {:expire_after => ttl})
          end
          ires.is_a?(Array) && ires[0] == 'OK'
        end
      end

      # Multi CAS
      #
      # Safe changing multiple keys at once. It works only with keys holding a value, eg, read/writeable with get/set
      #
      # @example
      #
      #   storewithcas.cas_multi('key1','key1') do |currenthash|
      #     newhashedvalues = make_something_with_current(currenthash)
      #     newhashedvalues
      #   end
      #
      # @example
      #   storewithcas.cas_multi('k1','k2', :expire_in => 1200) do |currenthash| #=> ttl for all keys swapped
      #     {'k1' => '1', 'k2' => 2}
      #   end
      #
      # @yield [values] a key=>value hash with values of given keys. keys not existing are not yielded
      # @yieldparam [Array] keys the keys to change
      # @yieldreturn [Hash] key-value-pairs to change. Keys not given in parameter or not existing in redis are ignored.
      # @return [Boolean] true if tried making changes, nil when keylist empty
      # @param keys [Array] the keys to set. Must not be nil and keys must exists in Redis. After keys list you may append hash with options for redis.
      def cas_multi(*keys)
        return if keys.empty?
        options = extract_options keys
        watch(*keys) do
          values = read_multi(*keys,options)
          valuehash = yield values
          valuehash.map do |name,value|
            multi do |multi|
              multi.set(name,value,options)
            end if values.key?(name)
          end
          true
        end
      end

      # Read list of keys and return values as Hash
      #
      # @param keys Array the keys to read
      # @return [Hash] key-value-pairs of key found in redis, eg, exists.
      #
      # @example
      #  values = read_multi("key1","key2","key3") #=> {"key1" => "1", "key2" => "2", "key3" => "3"}
      def read_multi(*keys)
        options = extract_options keys
        keys = keys.select {|k| exists(k)}
        return {} if keys.empty?
        values = mget(*keys,options)
        values.nil? ? {} : Hash[keys.zip(values)]
      end

      private

      def extract_options(array)
        if array.last.is_a?(Hash) && array.last.instance_of?(Hash)
          array.pop
        else
          {}
        end
      end
    end

  end
end
