# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lsa/version"

Gem::Specification.new do |spec|
  spec.name          = "lsa"
  spec.version       = Lsa::VERSION
  spec.authors       = ["Ryan Moore"]
  spec.email         = ["moorer@udel.edu"]

  spec.summary       = %q{Latent semantic analysis pipeline for genomes and metagenomes}
  spec.description   = %q{Latent semantic analysis pipeline for genomes and metagenomes}
  spec.homepage      = "https://github.com/mooreryan/lsa"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'abort_if', '~> 0.2.0'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'guard-rspec', '~> 4.7', '>= 4.7.3'
end
