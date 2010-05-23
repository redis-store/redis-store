gem "redis", "2.0.0"

group :development do
  gem "jeweler"
  gem "git"
end

group :development, :test, :rails3 do
  gem "ruby-debug"
  gem "rspec"
  gem "rack-cache"
  gem "merb"
end

if ENV["REDIS_STORE_ENV"] == "rails3"
  group :rails3 do
    gem "rack", "1.1.0"
    gem "activesupport", "3.0.0.beta3"
    gem "actionpack", "3.0.0.beta3"
  end
else
  group :test do
    gem "rack", "1.0.0"
    gem "activesupport", "2.3.5"
    gem "actionpack", "2.3.5"
  end
end
