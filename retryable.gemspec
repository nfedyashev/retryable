# rubocop:disable Style/ExpandPathArguments
lib = File.expand_path('../lib', __FILE__)
# rubocop:enable Style/ExpandPathArguments

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'retryable/version'

Gem::Specification.new do |spec|
  spec.name    = 'retryable'
  spec.version = Retryable::Version
  spec.authors = ['Nikita Fedyashev', 'Carlo Zottmann', 'Chu Yeow']
  spec.email   = ['nfedyashev@gmail.com']

  spec.summary     = 'Retrying code blocks in Ruby'
  spec.description = spec.summary
  spec.homepage    = 'http://github.com/nfedyashev/retryable'
  spec.licenses    = ['MIT']

  spec.require_paths = ['lib']
  spec.files         = Dir['{config,lib,spec}/**/*', '*.md', '*.gemspec', 'Gemfile', 'Rakefile']
  spec.test_files    = spec.files.grep(%r{^spec/})

  spec.required_ruby_version     = Gem::Requirement.new('>= 1.9.3')
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')

  spec.add_development_dependency 'bundler', '~> 1.0'
end
