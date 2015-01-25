# -*- encoding: utf-8 -*-
# stub: xcodeproj 0.20.2 ruby lib

Gem::Specification.new do |s|
  s.name = "xcodeproj"
  s.version = "0.20.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Eloy Duran"]
  s.date = "2014-11-15"
  s.description = "Xcodeproj lets you create and modify Xcode projects from Ruby. Script boring management tasks or build Xcode-friendly libraries. Also includes support for Xcode workspaces (.xcworkspace) and configuration files (.xcconfig)."
  s.email = "eloy.de.enige@gmail.com"
  s.executables = ["xcodeproj"]
  s.files = ["bin/xcodeproj"]
  s.homepage = "https://github.com/cocoapods/xcodeproj"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.2.2"
  s.summary = "Create and modify Xcode projects from Ruby."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3"])
      s.add_runtime_dependency(%q<colored>, ["~> 1.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 3"])
      s.add_dependency(%q<colored>, ["~> 1.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3"])
    s.add_dependency(%q<colored>, ["~> 1.2"])
  end
end
