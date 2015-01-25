# -*- encoding: utf-8 -*-
# stub: nap 0.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "nap"
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Manfred Stienstra"]
  s.date = "2014-05-31"
  s.description = "    Nap is a really simple REST library. It allows you to perform HTTP requests\n    with minimal amounts of code.\n"
  s.email = "manfred@fngtps.com"
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["LICENSE", "README.md"]
  s.homepage = "https://github.com/Fingertips/nap"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=utf-8"]
  s.rubygems_version = "2.2.2"
  s.summary = "Nap is a really simple REST library."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 10"])
      s.add_development_dependency(%q<peck>, ["~> 0.5"])
    else
      s.add_dependency(%q<rake>, ["~> 10"])
      s.add_dependency(%q<peck>, ["~> 0.5"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 10"])
    s.add_dependency(%q<peck>, ["~> 0.5"])
  end
end
