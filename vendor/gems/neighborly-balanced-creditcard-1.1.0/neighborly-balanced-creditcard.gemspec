# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neighborly/balanced/creditcard/version'

Gem::Specification.new do |spec|
  spec.name          = 'neighborly-balanced-creditcard'
  spec.version       = Neighborly::Balanced::Creditcard::VERSION
  spec.authors       = ['Josemar Luedke', 'Irio Musskopf']
  spec.email         = %w(josemarluedke@gmail.com iirineu@gmail.com)
  spec.summary       = 'Neighbor.ly integration with Credit Card Balanced Payments.'
  spec.description   = 'Integration with Balanced Payments on Neighbor.ly specifically with Credit Cards.'
  spec.homepage      = 'https://github.com/neighborly/neighborly-balanced-creditcard'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'neighborly-balanced', '~> 1.1'

  spec.add_dependency 'rails', '~> 4.0'
  spec.add_dependency 'slim', '~> 2.0'
  spec.add_development_dependency 'rspec-rails', '~> 2.14'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
