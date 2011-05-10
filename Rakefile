# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "retryable"
  gem.homepage = "http://github.com/carlo/retryable"
  gem.license = "MIT"
  gem.summary = %Q{Kernel#retryable, allow for retrying of code blocks.}
  gem.description = %Q{Kernel#retryable, allow for retrying of code blocks.}
  gem.email = "carlo@zottmann.org"
  gem.authors = ["Carlo Zottmann", "Chu Yeow", "Nikita Fedyashev"]

  gem.add_development_dependency 'bundler', ['>= 1.0.0']
  gem.add_development_dependency 'rspec', '~> 2.5.0'

end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "retryable #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
