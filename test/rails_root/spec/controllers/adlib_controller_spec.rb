require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdlibController do

  before(:each) do
    @page = flexmock(:model, AdlibPage)
    @page.should_receive(:layout).and_return('inside')
  end
  
  describe "(routing)" do

    it "should recognize GET /adlib/foo/bar/baz" do
      params_from(:get, '/adlib/foo/bar/baz').should ==
                 {:controller => 'adlib', :action => 'get', :path => %w{ foo bar baz }}
    end
    
  end

  it "should return a file on GET (with an existant file path)" do
    get 'get', :path => %w{ javascripts tiny_mce license.txt }
    FileUtils.rm_rf File.expand_path(RAILS_ROOT + '/public/adlib')
    
    response.should be_redirect
    response.should redirect_to('/adlib/javascripts/tiny_mce/license.txt')
  end

  it "should return 404 on GET (with non-existant file path)" do
    get 'get', :path => %w{ non existant file }
    
    response.should_not be_success
    response.code.should == '404'
  end
  
end
