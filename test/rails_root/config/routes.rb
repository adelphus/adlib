ActionController::Routing::Routes.draw do |map|
  map.resource :adlib_session, :path_prefix => 'adlib', :as => 'session'
  map.resources :adlib_pages, :path_prefix => 'adlib', :as => 'pages' do |pages|
    pages.resources :snippets, :controller => 'adlib_snippets'
  end
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  # Default route for Adlib pages
  map.connect '*path', :controller => 'adlib_pages', :action => 'show'  
end
