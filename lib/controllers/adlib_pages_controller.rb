class AdlibPagesController < ActionController::Base
  append_view_path File.expand_path(File.dirname(__FILE__) + '/../views') 
  
  def show
    @adlib_page = AdlibPage.find_by_path(params[:path]) if params[:path]
    @adlib_page = AdlibPage.find(params[:id].to_i)      if params[:id]
    render :template => @adlib_page.layout
  rescue ActiveRecord::RecordNotFound
    render :text => 'Page not found', :status => 404
  end
  
end
