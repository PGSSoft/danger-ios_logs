lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ios_logs/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-ios_logs'
  spec.version       = IosLogs::VERSION
  spec.authors       = ['Bartosz Janda', 'Joanna Bednarz']
  spec.email         = ['bjanda@pgs-soft.com', 'jbednarz@pgs-soft.com']
  spec.description   = 'Danger plugin to detect any NSLog/print entries left in the code'
  spec.summary       = 'Scan whole iOS project and detects usage of any NSLog/print entries in the code'
  spec.homepage      = 'https://github.com/PGSSoft/danger-ios_logs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'
  spec.add_runtime_dependency 'git_diff_parser', '~> 2.3'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 12.3'

  # Testing support
  spec.add_development_dependency 'rspec', '~> 3.4'

  # Linting code and docs
  spec.add_development_dependency 'rubocop', '~> 0.49'
  spec.add_development_dependency 'yard', '~> 0.9.11'

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry', '~> 0.10'
end
