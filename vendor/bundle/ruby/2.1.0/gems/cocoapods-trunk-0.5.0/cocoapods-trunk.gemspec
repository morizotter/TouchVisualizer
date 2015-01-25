# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_trunk'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-trunk"
  spec.version       = CocoaPodsTrunk::VERSION
  spec.authors       = ["Eloy Durán"]
  spec.email         = ["eloy.de.enige@gmail.com"]
  spec.summary       = "Interact with trunk.cocoapods.org"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'nap', '>= 0.8'
  spec.add_dependency 'netrc', '0.7.8'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.required_ruby_version = '>= 2.0.0'
end
