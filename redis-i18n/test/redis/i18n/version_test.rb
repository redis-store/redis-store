require 'test_helper'

describe Redis::I18n::VERSION do
  it 'returns current version' do
    Redis::I18n::VERSION.must_equal '0.6.5'
  end
end
