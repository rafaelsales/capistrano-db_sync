# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/db_sync/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-db_sync"
  spec.version       = Capistrano::DBSync::VERSION
  spec.authors       = ["Rafael Sales"]
  spec.email         = ["rafaelcds@gmail.com"]
  spec.summary       = %q{A capistrano task to import remote Postgres databases}
  spec.description   = %q{Fast download and restore dumps using edge features of Postgres 9.x}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "capistrano", ">= 3.0.0"
end
