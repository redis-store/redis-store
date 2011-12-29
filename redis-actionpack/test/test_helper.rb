Bundler.setup
gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'mocha'
require 'active_support/core_ext/numeric/time'
require 'action_dispatch'
require 'action_dispatch/middleware/session/redis_store'