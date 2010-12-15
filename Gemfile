source :gemcutter
gem "redis", ">= 2.0.0"

group :development do
  gem "jeweler"
  gem "git"
end

group :development, :test, :rails3 do
  gem "rack"
  gem "rack-cache"
  gem "merb", "1.1.0"
  gem "rspec", "1.3.0"
  gem "i18n"

  if RUBY_VERSION > '1.9'
    gem "methopara" # required by merb.
  else
    gem "ruby-debug" # linecache isn't compatible with 1.9.2 yet.
  end
end

if ENV["REDIS_STORE_ENV"] == "rails3"
  group :rails3 do
    gem "activesupport", "3.0.3"
    gem "actionpack", "3.0.3"
  end
else
  group :test do
    gem "activesupport", "2.3.10"
    gem "actionpack", "2.3.10"
  end
end
