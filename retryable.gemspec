require File.expand_path('../lib/retryable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.authors = ['Nikita Fedyashev', 'Carlo Zottmann', 'Chu Yeow']
  gem.description = 'Retryable#retryable, allow for retrying of code blocks.'
  gem.email = 'nfedyashev@gmail.com'
  gem.files = %w[CHANGELOG.md LICENSE.md README.md Rakefile retryable.gemspec]
  gem.files += Dir.glob('lib/**/*.rb')
  gem.files += Dir.glob('spec/**/*')
  gem.homepage = 'http://github.com/nfedyashev/retryable'
  gem.name = 'retryable'
  gem.license = 'MIT'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = '>= 1.3.6'
  gem.summary = gem.description
  gem.test_files = Dir.glob('spec/**/*')
  gem.version = Retryable::Version
end
