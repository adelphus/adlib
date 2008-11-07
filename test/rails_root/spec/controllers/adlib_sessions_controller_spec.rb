require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdlibSessionsController do

  before(:each) do
    @user = flexmock(:model, AdlibUser)
    flexmock(AdlibUser).should_receive(:find_by_username).with('johndoe').and_return(@user).by_default
    request.env['HTTP_REFERER'] = '/'
  end
  
  describe "(routing)" do

    it "should recognize GET /adlib/session/new" do
      params_from(:get, '/adlib/session/new').should ==
                 {:controller => 'adlib_sessions', :action => 'new'}
    end

    it "should recognize POST /adlib/session" do
      params_from(:post, '/adlib/session').should ==
                 {:controller => 'adlib_sessions', :action => 'create'}
    end

    it "should recognize DELETE /adlib/session" do
      params_from(:delete, '/adlib/session').should ==
                 {:controller => 'adlib_sessions', :action => 'destroy'}
    end

  end
  
  describe "(not logged in)" do

    it "should render 'adlib_session/new' on NEW" do
      get 'new'

      response.should render_template('adlib_sessions/new')
      assigns[:adlib_user].should_not be_nil
    end

    it "should render 'adlib_session/new' on an unsuccessful CREATE" do
      @user.should_receive(:authenticated?).with('wrong').and_return(false)
      
      post 'create', {:adlib_user => {:username => 'johndoe', :password => 'wrong'}}
      
      response.should render_template('adlib_sessions/new')
      assigns[:adlib_user].should == @user
    end

    it "should redirect to / on a successful CREATE" do
      @user.should_receive(:authenticated?).with('password').and_return(true)
      
      post 'create', {:adlib_user => {:username => 'johndoe', :password => 'password'}}

      response.should redirect_to('/')
    end

    it "should establish a session on a successful CREATE" do
      @user.should_receive(:authenticated?).with('password').and_return(true)
      
      post 'create', {:adlib_user => {:username => 'johndoe', :password => 'password'}}
      
      session[:adlib_user_id].should == @user.id
    end

    it "should redirect to / on DESTROY" do
      post 'destroy'

      response.should redirect_to('/')
    end

  end

  describe "(logged in)" do
  
    before(:each) do
      session[:adlib_user_id] = @user.id
    end

    it "should redirect to '/' on NEW, while keeping the session" do
      get 'new'

      response.should redirect_to('/')
      session[:adlib_user_id].should == @user.id
    end

    it "should delete the session on an unsuccessful CREATE" do
      @user.should_receive(:authenticated?).with('wrong').and_return(false)
      
      post 'create', {:adlib_user => {:username => 'johndoe', :password => 'wrong'}}
      
      session[:adlib_user_id].should be_nil    end

    it "should delete the session on DESTROY" do
      post 'destroy'

      session[:adlib_user_id].should be_nil
    end  
  end

end
