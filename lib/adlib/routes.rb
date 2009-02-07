ActionController::Routing::Routes.class.class_eval do  
  def draw_with_adlib
    draw_without_adlib do |map|

      # Adlib management routes
      map.resource :adlib_session, :path_prefix => 'adlib', :as => 'session'
      map.resources :adlib_pages, :path_prefix => 'adlib', :as => 'pages', :collection => { :sort => :put } do |pages|
        pages.resources :snippets, :controller => 'adlib_snippets'
        pages.resources :images, :controller => 'adlib_images'
      end
      map.connect 'adlib/*path', :controller => 'adlib', :action => 'get'

      yield map

      # Adlib dynamic page route
      map.connect '*path', :controller => 'adlib_pages', :action => 'show'  

    end
  end
  alias_method_chain :draw, :adlib
end
