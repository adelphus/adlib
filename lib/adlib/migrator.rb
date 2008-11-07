module Adlib
  class Migrator

    def self.migration_directory
      File.dirname(__FILE__) + "/../../db/migrate"
    end

    # convenience class level method
    def self.migrate(version=nil,needs_connection=false)
      self.new.migrate(version,needs_connection)
    end
    
    attr_accessor :yaml

    # initializes, reading in the rails database.yml file  
    def initialize
      File.open(RAILS_ROOT + '/config/database.yml') { |f| 
        @yaml= YAML::load(f) 
      }
    end

    # performs the migration
    def migrate(version=nil, needs_connection=false)
      establish_connection if needs_connection

      do_migrate(self.class.migration_directory,version)
    end

    protected 

    # establishes an active record connection
    def establish_connection
      raise "No RAILS_ENV is defined" unless defined?(RAILS_ENV)
      ActiveRecord::Base.establish_connection(@yaml[RAILS_ENV])
    end

    # performs the actual migration
    def do_migrate(migrate_dir,version)
      version = version.to_i if version
      ActiveRecord::Migrator.migrate(migrate_dir, version).inspect
    end

  end
 
end
