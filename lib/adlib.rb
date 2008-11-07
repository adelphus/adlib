require 'adlib/migrator'
Adlib::Migrator.migrate(ENV['VERSION'], false)

require 'models/adlib_user'
