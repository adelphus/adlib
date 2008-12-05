require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/adlib/sessions/new' do

  before(:each) do
    @controller.view_paths = File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/views')
    @user = flexmock(:model, AdlibUser)
    @user.errors.should_receive(:empty?).and_return(true).by_default
    @user.should_receive(:username).and_return(nil).by_default
    @user.should_receive(:password).and_return(nil).by_default
    assigns[:adlib_user] = @user
  end
  
  it "should display a login form with username and password fields" do
    render '/adlib_sessions/new'
    
    response.should have_tag('input[name=?]', 'adlib_user[username]')
    response.should have_tag('input[name=?]', 'adlib_user[password]')
    response.should have_tag('input[value=?]', 'Log In')
  end

  it "should display an error message after an unsuccessful login attempt" do
    @user.errors.should_receive(:empty?).and_return(false)
    @user.errors.should_receive(:on_base).and_return('Login failed.')

    render '/adlib_sessions/new'
    
    response.should have_tag('.error', 'Login failed.')
  end

  it "should not display an error message when no login was attempted" do
    render '/adlib_sessions/new'
    
    response.should_not have_tag('.error')
  end

end
