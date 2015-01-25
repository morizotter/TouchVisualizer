# -*- encoding: utf-8 -*-
# stub: cocoapods-plugins 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-plugins"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["David Grandinetti", "Olivier Halligon"]
  s.date = "2014-12-25"
  s.description = "                         This CocoaPods plugin shows information about all available CocoaPods plugins\n                         (yes, this is very meta!).\n                         This CP plugin adds the \"pod plugins\" command to CocoaPods so that you can list\n                         all plugins (registered in the reference JSON hosted at CocoaPods/cocoapods-plugins)\n"
  s.homepage = "https://github.com/cocoapods/cocoapods-plugins"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.2.2"
  s.summary = "CocoaPods plugin which shows info about available CocoaPods plugins."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nap>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<nap>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<nap>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
