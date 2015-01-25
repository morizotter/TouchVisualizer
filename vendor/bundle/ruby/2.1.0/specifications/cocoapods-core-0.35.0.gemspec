# -*- encoding: utf-8 -*-
# stub: cocoapods-core 0.35.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-core"
  s.version = "0.35.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Eloy Duran", "Fabio Pelosin"]
  s.date = "2014-11-19"
  s.description = "The CocoaPods-Core gem provides support to work with the models of CocoaPods.\n\n It is intended to be used in place of the CocoaPods when the the installation of the dependencies is not needed."
  s.email = ["eloy.de.enige@gmail.com", "fabiopelosin@gmail.com"]
  s.homepage = "https://github.com/CocoaPods/CocoaPods"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.2.2"
  s.summary = "The models of CocoaPods"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2.15"])
      s.add_runtime_dependency(%q<nap>, ["~> 0.8.0"])
      s.add_runtime_dependency(%q<fuzzy_match>, ["~> 2.0.4"])
      s.add_development_dependency(%q<bacon>, ["~> 1.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.2.15"])
      s.add_dependency(%q<nap>, ["~> 0.8.0"])
      s.add_dependency(%q<fuzzy_match>, ["~> 2.0.4"])
      s.add_dependency(%q<bacon>, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.2.15"])
    s.add_dependency(%q<nap>, ["~> 0.8.0"])
    s.add_dependency(%q<fuzzy_match>, ["~> 2.0.4"])
    s.add_dependency(%q<bacon>, ["~> 1.1"])
  end
end
