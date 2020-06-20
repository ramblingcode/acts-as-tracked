# frozen_string_literal: true

require 'rails/generators/migration'

module ActsAsTracked
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    MIGRATION_TIMESTAMP_FORMAT = '%Y%m%d%H%M%S'

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'active_record')
    end

    def self.next_migration_number(_path)
      Time.now.utc.strftime(MIGRATION_TIMESTAMP_FORMAT)
    end

    def create_migration_file
      migration_template  'migration.erb',
                          'db/migrate/acts_as_tracked_migration.rb'
      { migration_version: migration_version }
    end

    private

    # Rails 5.x+ requires Rails version to
    # be specified in migration file

    def migration_version
      migration_versions = {
        '5' => '[5.0]',
        '6' => '[6.0]'
      }

      migration_versions.fetch(
        Rails.version[0],
        nil
      )
    end
  end
end
