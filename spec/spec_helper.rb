# frozen_string_literal: true

require 'bundler/setup'
require 'acts_as_tracked'

require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'combustion'

# ON CI Environment use internal/config/schema.rb

database_reset, load_schema = if ENV['PREPARE_COMBUSTION_DB_USING_SCHEMA']
                                [true, true]
                              else
                                [false, false]
                              end

Combustion.initialize! :active_record, :active_support, database_reset: database_reset, load_schema: load_schema

require 'rspec/rails'

require 'with_model'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.use_transactional_fixtures = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.extend WithModel
end
