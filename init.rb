bns_path = File.dirname(File.expand_path(__FILE__)) + "/vendor/plugins/betternestedset"
$LOAD_PATH <<  "#{bns_path}/lib"
init_path = "#{bns_path}/init.rb"
silence_warnings { eval(IO.read(init_path), binding, init_path) }

require 'adlib'
