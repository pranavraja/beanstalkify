# -*- encoding: utf-8 -*- 
$:.push File.expand_path("../lib", __FILE__)
require 'beanstalkify/version'

Gem::Specification.new do |s|
  s.name          = 'beanstalkify'
  s.version       = Beanstalkify::VERSION
  s.summary       = "Beanstalk automation for dummies"
  s.description   = "Create Amazon Elastic Beanstalk apps and deploy versions from the command line"
  s.authors       = ["Pranav Raja"]
  s.email         = 'rickdangerous1@gmail.com'
  s.files         = `git ls-files`.split("\n")  
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")  
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }  
  s.require_paths = ["lib"]  
  s.homepage      = 'https://github.com/pranavraja/beanstalkify'
  s.license       = 'MIT'

  s.add_dependency 'aws-sdk'
  s.add_development_dependency "rspec"
end
