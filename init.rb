require 'vendor/plugins/betternestedset/lib/better_nested_set'
require 'vendor/plugins/betternestedset/lib/better_nested_set_helper'

ActiveRecord::Base.class_eval do
  include SymetrieCom::Acts::NestedSet
end
ActionView::Base.send :include, SymetrieCom::Acts::BetterNestedSetHelper

require 'adlib'
