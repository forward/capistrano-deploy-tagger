# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "capistrano-deploy-tagger"
  s.version     = "2.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ryan Conway"]
  s.email       = ["ryan.conway@forward.co.uk"]
  s.homepage    = "http://github.com/rylon/capistrano-deploy-tagger"
  s.summary     = %q{Capistrano-Deploy-Tagger creates and updates certain tags in Git each time you perform a deploy.}
  s.description = %q{Capistrano-Deploy-Tagger creates and updates certain tags in Git each time you perform a deploy. The first tag defaults to 'inproduction' and is always updated to refer to the revision that was just deployed. The second tag is a timestamp applied to every revision that is deployed to production.}

  s.rubyforge_project = "capistrano-deploy-tagger"

  s.files = ["lib/capistrano/deploy/tagger.rb"]
  s.require_paths = ["lib"]

  s.add_dependency("capistrano", [">= 1.0.0"])

  s.has_rdoc = false
end