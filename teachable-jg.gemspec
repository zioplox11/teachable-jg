# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teachable/jg/version'

Gem::Specification.new do |spec|
  spec.name          = "teachable-jg"
  spec.version       = Teachable::Jg::VERSION
  spec.authors       = ["Joshua"]
  spec.email         = ["joshua.guthals@gmail.com"]

  spec.summary       = %q{A convenient wrapper for the valid endpoints of Teachable Mock API}
  spec.description   = %q{A convenient wrapper for the valid endpoints of Teachable Mock API}
  spec.homepage      = "https://github.com/zioplox11/teachable-jg" # place holder for now

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "https://mygemserver.com"  # commenting out for now
  # end

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "httparty"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock", "1.24.2"
end
