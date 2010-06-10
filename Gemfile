source :gemcutter
gem "redis", ">= 2.0.0"

group :development do
  gem "jeweler"
  gem "git"
end

group :development, :test, :rails3 do
  gem "rack"
  gem "ruby-debug"
  gem "rspec"
  gem "rack-cache"
  gem "merb"
  gem "methopara" if RUBY_VERSION.match /1\.9/
end

if ENV["REDIS_STORE_ENV"] == "rails3"
  group :rails3 do
    gem "activesupport", "3.0.0.beta4"
    gem "actionpack", "3.0.0.beta4"
  end
else
  group :test do
    gem "activesupport", "2.3.8"
    gem "actionpack", "2.3.8"
  end
end
