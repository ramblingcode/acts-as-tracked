# frozen_string_literal: true

require_relative 'lib/acts_as_tracked/version'

Gem::Specification.new do |spec|
  spec.name          = 'acts_as_tracked'
  spec.version       = ActsAsTracked::VERSION
  spec.authors       = ['Sahil Gadimbayli']
  spec.email         = ['sahil.gadimbay@gmail.com']

  spec.summary       = 'Activity Tracker to plug into ActiveRecord.'
  spec.description   = 'Track activities in your activerecord models.'
  spec.homepage      = 'https://github.com/ramblingcode/acts-as-tracked'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 4.2'

  spec.add_development_dependency 'rubocop'
end
