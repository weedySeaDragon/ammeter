# -*- encoding: utf-8 -*-
require File.expand_path('../lib/my_railties_gem/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Rothenberg"]
  gem.email         = ["alex@alexrothenberg.com"]
  gem.description   = %q{Write specs for your Rails 3+ generators (the railties version)}
  gem.summary       = %q{Write specs for your Rails 3+ generators (the railties version)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "my_railties_gem"
  gem.require_paths = ["lib"]
  gem.version       = MyRailtiesGem::VERSION

  gem.add_runtime_dependency     'railties', '>= 3.2'
end
