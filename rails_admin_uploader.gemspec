# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_admin_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_admin_uploader"
  spec.version       = RailsAdminUploader::VERSION
  spec.authors       = ["glebtv"]
  spec.email         = ["glebtv@gmail.com"]

  spec.summary       = %q{Mass file uploads via jQuery-File-Upload for Rails Admin}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/rs-pro/rails_admin_uploader"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
