class AdlibController < ActionController::Base
  
  def get
    filename = params[:path].join('/')

    unless File.exist?(File.expand_path(public_path + filename))
      render :text => '', :status => 404
      return    
    end

    move_to_public_adlib filename
    redirect_to '/adlib/' + filename
  end
  
  private
  
    def public_path
      @public_path ||= File.dirname(__FILE__) + '/../../public/'
    end

    def public_adlib_path
      @public_adlib_path ||= RAILS_ROOT + '/public/adlib/'
    end
    
    def move_to_public_adlib(filename)
      destination = File.dirname(public_adlib_path + filename)
      FileUtils.mkdir_p destination
      FileUtils.cd public_path
      FileUtils.cp filename, destination
    end
  
end
