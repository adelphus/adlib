require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdlibPagesController do

  before(:each) do
    @page = flexmock(:model, AdlibPage)
    @page.should_receive(:layout).and_return('inside')
  end
  
  describe "(routing)" do

    it "should recognize GET /adlib/pages/42" do
      params_from(:get, '/adlib/pages/42').should ==
                 {:controller => 'adlib_pages', :action => 'show', :id => '42'}
    end
    
    it "should recognize GET /foo/bar/baz" do
      params_from(:get, '/foo/bar/baz').should ==
                 {:controller => 'adlib_pages', :action => 'show', :path => %w{ foo bar baz }}
    end
    
  end

  it "should render a page on SHOW (with valid id)" do
    flexmock(AdlibPage).should_receive(:find).with(@page.id).and_return(@page)
    
    get 'show', :id => @page.id.to_s
    
    response.should render_template('inside')
    assigns[:adlib_page].should == @page
  end

  it "should render a page on SHOW (with valid path)" do
    flexmock(AdlibPage).should_receive(:find_by_path).with(%w{ foo bar baz }).and_return(@page)
    
    get 'show', :path => %w{ foo bar baz }
    
    response.should render_template('inside')
    assigns[:adlib_page].should == @page
  end
  
  it "should return 404 on SHOW (with invalid id)" do
    get 'show', :id => '0'
    
    response.should_not be_success
    response.code.should == '404'
  end
  
  it "should return 404 on SHOW (with invalid path)" do
    get 'show', :path => %w{ invalid path }
    
    response.should_not be_success
    response.code.should == '404'
  end

end
