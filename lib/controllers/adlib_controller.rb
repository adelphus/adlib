class AdlibController < ActionController::Base
  
  def get
    filename = params[:path].join('/')
    destination = File.dirname(RAILS_ROOT + '/public/adlib/' + filename)
    if File.exist?(File.expand_path(File.dirname(__FILE__) + '/../../public/' + filename))
      FileUtils.cd File.expand_path(File.dirname(__FILE__) + '/../../public')
      FileUtils.mkdir_p destination
      FileUtils.cp filename, destination
      redirect_to '/adlib/' + filename
    else
      render :text => '', :status => 404
    end
  end
  
end
