ActionController::Routing::Routes.draw do |map|
  map.resource :adlib_session, :path_prefix => 'adlib', :as => 'session'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
