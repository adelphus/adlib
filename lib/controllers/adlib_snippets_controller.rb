class AdlibSnippetsController <  ActionController::Base
  append_view_path File.expand_path(File.dirname(__FILE__) + '/../views') 
  append_before_filter :logged_in?, :load_current_page

  def new
    @adlib_snippet = AdlibSnippet.new :page => @adlib_page, 
                                      :slot => params[:slot]
  end
  
  def create
    new
    @adlib_snippet.attributes = params[:adlib_snippet]

    respond_to do |format|
      if @adlib_snippet.save
        format.html { redirect_to @adlib_page.full_slug }
        format.xml  { render :inline => '<success />', :status => :ok }
      else
        format.html { render :template => 'adlib_snippets/new' }
        format.xml  { render :xml => @adlib_snippet.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @adlib_snippet = AdlibSnippet.find(params[:id].to_i)
  end

  def update
    edit
    @adlib_snippet.attributes = params[:adlib_snippet]

    respond_to do |format|
      if @adlib_snippet.save
        format.html { redirect_to @adlib_page.full_slug }
        format.xml  { render :inline => '<success />', :status => :ok }
      else
        format.html { render :template => 'adlib_snippets/edit' }
        format.xml  { render :xml => @adlib_snippet.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected
  
  def logged_in?
    if session[:adlib_user_id]
      true
    else
      redirect_to new_adlib_session_path
    end
  end

  def load_current_page
    @adlib_page = AdlibPage.find(params[:adlib_page_id].to_i)    
  end
  
end
