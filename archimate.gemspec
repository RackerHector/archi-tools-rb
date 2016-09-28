# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'archimate/version'

Gem::Specification.new do |spec|
  spec.name          = "archimate"
  spec.version       = Archimate::VERSION
  spec.authors       = ["Mark Morga"]
  spec.email         = ["markmorga@gmail.com", "mmorga@rackspace.com"]

  spec.summary       = "Archi Tools"
  spec.description   = "A collection of tools for working with ArchiMate files from Archi"
  spec.homepage      = "http://markmorga.com/archi-tools-rb"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_runtime_dependency "dry-struct", "~> 0.1.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "colorize", "~> 0.7"
  spec.add_runtime_dependency "rmagick", "~> 2.15"
  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "highline", "~> 1.7"
  spec.add_runtime_dependency "ruby-progressbar", "~>1.8.1"
  spec.add_runtime_dependency "ox", "~> 2.4.3"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-matchers"
  spec.add_development_dependency "minitest-color"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "ruby_gntp"
  spec.add_development_dependency "ruby-prof"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "kramdown"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "guard-ctags-bundler"
  spec.add_development_dependency "faker"
end
