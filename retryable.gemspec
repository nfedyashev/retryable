# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name          = %q{retryable}
  s.version       = "1.3.0"
  s.authors       = ["Nikita Fedyashev", "Carlo Zottmann", "Chu Yeow"]
  s.date          = %q{2011-05-17}
  s.description   = %q{Kernel#retryable, allow for retrying of code blocks.}
  s.email         = %q{loci.master@gmail.com}
  s.files         = `git ls-files lib`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.homepage      = %q{http://github.com/nfedyashev/retryable}
  s.licenses      = ["MIT"]
  s.require_paths = ["lib"]
  s.summary       = %q{Kernel#retryable, allow for retrying of code blocks.}

  s.extra_rdoc_files = [
    "README.md"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.10.0"])
      s.add_development_dependency(%q<bundler>, [">=0"])
    end
  end

  s.required_rubygems_version = '>= 1.3.6'
end

