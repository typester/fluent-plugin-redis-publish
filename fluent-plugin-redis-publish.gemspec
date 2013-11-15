# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-redis-publish"
  gem.version       = "0.1.1"
  gem.authors       = ["Daisuke Murase"]
  gem.email         = ["typester@cpan.org"]
  gem.summary       = "fluent output plugin publishing logs to redis pub/sub"
  gem.homepage      = "https://github.com/typester/fluent-plugin-redis-publish"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "fluentd"
  gem.add_dependency "redis"
end
