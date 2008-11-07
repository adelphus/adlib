require 'adlib/migrator'
Adlib::Migrator.migrate(ENV['VERSION'], false)

require 'models/adlib_user'
require 'models/adlib_section'
require 'models/adlib_page'
require 'models/adlib_snippet'
