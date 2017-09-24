# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/results/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Results.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-results"
  s.summary = "A results component for decidim's participatory processes."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Results.version
  s.add_dependency "decidim-comments", Decidim::Results.version
  s.add_dependency "searchlight", "~> 4.1.0"
  s.add_dependency "kaminari", "~> 1.0.1"

  s.add_development_dependency "decidim-dev", Decidim::Results.version
  s.add_development_dependency "decidim-admin", Decidim::Results.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Results.version
  s.add_development_dependency "decidim-assemblies", Decidim::Results.version
  s.add_development_dependency "decidim-comments", Decidim::Results.version
  s.add_development_dependency "decidim-proposals", Decidim::Results.version
  s.add_development_dependency "decidim-meetings", Decidim::Results.version
end
