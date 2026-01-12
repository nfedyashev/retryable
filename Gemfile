source 'http://rubygems.org'

gem 'rake'
gem 'yard'

group :development do
  gem 'fasterer'
  gem 'pry', '= 0.9.12.6'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'bigdecimal'
  gem 'logger' if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('4.0.0')
  gem 'rspec', '~> 3.1'
end

gemspec
