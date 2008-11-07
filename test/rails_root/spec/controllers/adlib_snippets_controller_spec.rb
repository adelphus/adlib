require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdlibSnippetsController do
  
  describe "(routing)" do

    it "should recognize GET /adlib/pages/13/snippets/new" do
      params_from(:get, '/adlib/pages/13/snippets/new').should ==
                 {:controller => 'adlib_snippets', :action => 'new',
                  :adlib_page_id => '13' }
    end

    it "should recognize POST /adlib/pages/13/snippets" do
      params_from(:post, '/adlib/pages/13/snippets').should ==
                 {:controller => 'adlib_snippets', :action => 'create',
                  :adlib_page_id => '13'}
    end

    it "should recognize GET /adlib/pages/13/snippets/42/edit" do
      params_from(:get, '/adlib/pages/13/snippets/42/edit').should ==
                 {:controller => 'adlib_snippets', :action => 'edit',
                  :adlib_page_id => '13', :id => '42' }
    end

    it "should recognize POST /adlib/snippets/42" do
      params_from(:put, '/adlib/pages/13/snippets/42').should ==
                 {:controller => 'adlib_snippets', :action => 'update', 
                  :adlib_page_id => '13', :id => '42' }
    end

  end

  describe "(not logged in)" do
    
    it "should redirect to 'adlib/session/new' on NEW" do
      get 'new', :adlib_page_id => '13'
      
      response.should redirect_to(new_adlib_session_path)
    end

    it "should redirect to 'adlib/session/new' on CREATE" do
      post 'create', :adlib_page_id => '13'
      
      response.should redirect_to(new_adlib_session_path)
    end

    it "should redirect to 'adlib/session/new' on EDIT" do
      get 'edit', :adlib_page_id => '13', :id => '42'
      
      response.should redirect_to(new_adlib_session_path)
    end

    it "should redirect to 'adlib/session/new' on UPDATE" do
      post 'update', :adlib_page_id => '13', :id => '42'
      
      response.should redirect_to(new_adlib_session_path)
    end
  
  end

  describe "(logged in)" do
  
    before(:each) do
      @adlib_user = flexmock(:model, AdlibUser)
      @adlib_page = flexmock(:model, AdlibPage)      
      @adlib_snippet = flexmock(:model, AdlibSnippet)      
      session[:adlib_user_id] = @adlib_user.id
      flexmock(AdlibPage).should_receive(:find).with(@adlib_page.id).and_return(@adlib_page)
      flexmock(AdlibSnippet).should_receive(:find).with(@adlib_snippet.id).and_return(@adlib_snippet)
    end

    it "should render 'adlib_snippets/new' on NEW" do
      get 'new', :adlib_page_id => @adlib_page.id.to_s, :slot => 'main'
      
      response.should render_template('adlib_snippets/new')
      assigns[:adlib_snippet].should_not be_nil
      assigns[:adlib_snippet].page_id.should == @adlib_page.id
      assigns[:adlib_snippet].slot.should == 'main'
    end

    it "should render 'adlib_snippets/new' on an unsuccessful CREATE" do
      flexmock(AdlibSnippet).should_receive(:new).and_return(@adlib_snippet)
      @adlib_snippet.should_receive(:attributes=).with('slot' => 'main', 'content' => '<p>Hello World!</p>')
      @adlib_snippet.should_receive(:save).and_return(false)

      post 'create', :adlib_page_id => @adlib_page.id.to_s, :adlib_snippet => { :slot => 'main', 
                                                                                :content => '<p>Hello World!</p>' }
      
      response.should render_template('adlib_snippets/new')
      assigns[:adlib_snippet].should == @adlib_snippet
    end

    it "should redirect to the page view on a successful CREATE" do
      flexmock(AdlibSnippet).should_receive(:new).and_return(@adlib_snippet)
      @adlib_snippet.should_receive(:attributes=).with('slot' => 'main', 'content' => '<p>Hello World!</p>')
      @adlib_snippet.should_receive(:save).and_return(true)
      @adlib_page.should_receive(:full_slug).and_return('/foo/bar/baz/')

      post 'create', :adlib_page_id => @adlib_page.id.to_s, :adlib_snippet => { :slot => 'main', 
                                                                                :content => '<p>Hello World!</p>' }
      
      response.should redirect_to('/foo/bar/baz/')
    end

    it "should create the snippet on a successful CREATE" do
      flexmock(AdlibSnippet).should_receive(:new).and_return(@adlib_snippet)
      @adlib_snippet.should_receive(:attributes=).with('slot' => 'main', 'content' => '<p>Something Else</p>')
      @adlib_snippet.should_receive(:save).and_return(true).once
      @adlib_page.should_receive(:full_slug).and_return('/foo/bar/baz/')

      post 'create', :adlib_page_id => @adlib_page.id.to_s, :adlib_snippet => { :slot => 'main', 
                                                                                :content => '<p>Something Else</p>' }
    end

    it "should render 'adlib_snippets/edit' on EDIT" do
      get 'edit', :adlib_page_id => @adlib_page.id.to_s, :id => @adlib_snippet.id.to_s
      
      response.should render_template('adlib_snippets/edit')
      assigns[:adlib_snippet].should_not be_nil
      assigns[:adlib_snippet].id.should == @adlib_snippet.id
    end

    it "should render 'adlib_snippets/edit' on an unsuccessful UPDATE" do
      @adlib_snippet.should_receive(:attributes=).with('content' => '<p>Hello World!</p>')
      @adlib_snippet.should_receive(:save).and_return(false)

      post 'update', :adlib_page_id => @adlib_page.id.to_s, :id => @adlib_snippet.id.to_s, 
                     :adlib_snippet => { :content => '<p>Hello World!</p>' }
      
      response.should render_template('adlib_snippets/edit')
      assigns[:adlib_snippet].should == @adlib_snippet
    end

    it "should redirect to the page view on a successful UPDATE" do
      @adlib_snippet.should_receive(:attributes=).with('content' => '<p>Hello World!</p>')
      @adlib_snippet.should_receive(:save).and_return(true)
      @adlib_page.should_receive(:full_slug).and_return('/foo/bar/baz/')

      post 'update', :adlib_page_id => @adlib_page.id.to_s, :id => @adlib_snippet.id.to_s,
                     :adlib_snippet => { :content => '<p>Hello World!</p>' }
      
      response.should redirect_to('/foo/bar/baz/')
    end

    it "should update the snippet content on a successful UPDATE" do
      @adlib_snippet.should_receive(:attributes=).with('content' => '<p>Something Else</p>')
      @adlib_snippet.should_receive(:save).and_return(true)
      @adlib_page.should_receive(:full_slug).and_return('/foo/bar/baz/')

      post 'update', :adlib_page_id => @adlib_page.id.to_s, :id => @adlib_snippet.id.to_s,
                     :adlib_snippet => { :content => '<p>Something Else</p>' }
    end
  
  end

end
