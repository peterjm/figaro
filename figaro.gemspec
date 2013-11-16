# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = "figaro"
  gem.version = "0.7.0"

  gem.author      = "Peter McCracken"
  gem.email       = "peter@petermccracken.com"
  gem.summary     = "Simple Ruby app configuration"
  gem.description = "Simple, Heroku-friendly Ruby app configuration using ENV and a single YAML file"
  gem.homepage    = "https://github.com/peterjm/figaro"
  gem.license     = "MIT"

  gem.add_dependency "bundler", "~> 1.0"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^(features|spec)/)
  gem.require_paths = ["lib"]
end
