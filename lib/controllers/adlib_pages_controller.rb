class AdlibPagesController < ActionController::Base
  layout 'application', :only => :show
  append_view_path File.expand_path(File.dirname(__FILE__) + '/../views') 
  
  def show
    @adlib_page = AdlibPage.find_by_path(params[:path]) if params[:path]
    @adlib_page = AdlibPage.find(params[:id].to_i)      if params[:id]
    render :template => @adlib_page.layout
  rescue ActiveRecord::RecordNotFound
    render :text => 'Page not found', :status => 404
  end

  def new
    @adlib_page = AdlibPage.new
  end

  def create
    new
    @parent = AdlibPage.find(params[:parent_id])
    @adlib_page.attributes = params[:adlib_page]

    if @adlib_page.slug.blank?
      @adlib_page.slug = @adlib_page.name.underscore.gsub(/\s/, '_') + '/'
    end

    respond_to do |format|
      if @parent and @adlib_page.save
        @adlib_page.move_to_child_of @parent
        format.html { redirect_to @adlib_page.full_slug }
        format.xml  { render :inline => "<success />", :status => :ok }
      else
        format.html { render :template => 'adlib_pages/new' }
        format.xml  { render :xml => @adlib_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @adlib_page = AdlibPage.find_by_path(params[:path]) if params[:path]
    @adlib_page = AdlibPage.find(params[:id].to_i)      if params[:id]
  end

  def update
    edit
    @adlib_page.attributes = params[:adlib_page]

    respond_to do |format|
      if @adlib_page.save
        format.html { redirect_to @adlib_page.full_slug }
        format.xml  { render :inline => "<redirect>#{@adlib_page.full_slug}</redirect>", :status => :ok }
      else
        format.html { render :template => 'adlib_pages/edit' }
        format.xml  { render :xml => @adlib_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @adlib_page = AdlibPage.find(params[:id].to_i)
    @adlib_page.destroy

    redirect_to :back
  end

  def sort
    order = params[:page]
    AdlibPage.order(order)
    render :text => order.inspect    
  end
  
end
