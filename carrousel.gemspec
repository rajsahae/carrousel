# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrousel/version'

Gem::Specification.new do |spec|
  spec.name          = "carrousel"
  spec.version       = Carrousel::VERSION
  spec.authors       = ["Raj Sahae"]
  spec.email         = ["rajsahae@gmail.com"]
  spec.description   = %q{Carrousel is a robust utility designed to take a list
  of generic items, and given some command, perform that command on each item
  in that list. Depending on the commands return value, Carrousel will track 
  which items have been completed successfully, and retry items as necessary.
  It will save your progress in a status database and you can quit the loop 
  and come back later to finish unprocessed items.}
  spec.summary       = %q{Robust list based action tracking utility.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
