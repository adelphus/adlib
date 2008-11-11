ActionController::Routing::Routes.draw do |map|

  # Adlib management routes
  map.resource :adlib_session, :path_prefix => 'adlib', :as => 'session'
  map.resources :adlib_pages, :path_prefix => 'adlib', :as => 'pages' do |pages|
    pages.resources :snippets, :controller => 'adlib_snippets'
    pages.resources :images, :controller => 'adlib_images'
  end
  
  # Adlib dynamic page route
  map.connect '*path', :controller => 'adlib_pages', :action => 'show'  

end
