class Redis
  class Store < self
    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 0
      TINY  = 0
      BUILD = "beta5"

      STRING = [MAJOR, MINOR, TINY, BUILD].join('.')
    end
  end
end
