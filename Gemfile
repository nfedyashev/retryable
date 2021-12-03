source 'http://rubygems.org'

gem 'rake', '~> 10.4'
gem 'yard'

# because json 2.3.0 is incompatible with Ruby 1.9.3
# https://stackoverflow.com/a/59368273/74089
gem 'json', '= 1.8.6'

group :development do
  gem 'fasterer'
  gem 'overcommit'
  gem 'pry', '= 0.9.12.6'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'rspec', '~> 3.1'
  gem 'simplecov', require: false
  gem 'simplecov_json_formatter', require: false
end

gemspec
