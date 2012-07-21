# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'yard'
  gem.authors = ["Nikita Fedyashev", "Carlo Zottmann", "Chu Yeow"]
  gem.description = %q{Kernel#retryable, allow for retrying of code blocks.}
  gem.email = %q{loci.master@gmail.com}
  gem.files = %w(CHANGELOG.md LICENSE.md README.md Rakefile retryable.gemspec)
  gem.files += Dir.glob("lib/**/*.rb")
  gem.files += Dir.glob("spec/**/*")
  gem.homepage = %q{http://github.com/nfedyashev/retryable}
  gem.name = 'retryable'
  gem.require_paths = ["lib"]
  gem.required_rubygems_version = '>= 1.3.6'
  gem.summary = %q{Kernel#retryable, allow for retrying of code blocks.}
  gem.test_files = Dir.glob("spec/**/*")
  gem.version = "1.3.0"
end
