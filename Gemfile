source :gemcutter
gem "redis", "~> 2.2.1"

group :development do
  gem "jeweler"
  gem "git"
end

group :development, :test, :rails3 do
  gem "rack-cache"
  gem "rspec", "1.3.0"
  gem "i18n"
  gem "debugger"
end

if ENV["REDIS_STORE_ENV"] == "rails3"
  group :rails3 do
    gem "rack", "~> 1.2.1"
    gem "activesupport", "3.0.5"
    gem "actionpack", "3.0.5"
  end
else
  group :test do
    gem "rack", "~> 1.1.0"
    gem "activesupport", "2.3.11"
    gem "actionpack", "2.3.11"
  end
end
