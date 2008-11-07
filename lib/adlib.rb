require 'RMagick'
require 'adlib/migrator'
Adlib::Migrator.migrate(ENV['VERSION'], false)

require 'controllers/adlib_sessions_controller'

require 'models/adlib_user'
require 'models/adlib_section'
require 'models/adlib_page'
require 'models/adlib_snippet'
require 'models/adlib_image'
