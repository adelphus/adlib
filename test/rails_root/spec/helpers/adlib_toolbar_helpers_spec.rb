require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdlibHelper, "adlib_page_toolbar" do

  describe "(not logged in)" do

    before do
      flexmock(self).should_receive(:adlib_logged_in?).and_return(false)
    end
    
    it "should not display the toolbar" do
      adlib_page_toolbar.should_not have_tag('div#adlib-page-toolbar')
    end

  end

  describe "(logged in)" do

    before do
      flexmock(self).should_receive(:adlib_logged_in?).and_return(true)
    end
    
    it "should display the toolbar" do
      adlib_page_toolbar.should have_tag('div#adlib-page-toolbar')
    end

  end
  
end

describe AdlibHelper, "powered_by_adlib" do

  it "should display powered by adlib" do
    powered_by_adlib.should have_tag('div#powered-by-adlib')
  end

  it "should display the link to adelphus" do
    powered_by_adlib.should have_tag('a#link-to-adelphus')
  end

  describe "(not logged in)" do

    before do
      flexmock(self).should_receive(:adlib_logged_in?).and_return(false)
    end

    it "should display the link to log in" do
      powered_by_adlib.should have_tag('a#link-to-adlib-session-new')
    end

    it "should not display the link to log out" do
      powered_by_adlib.should_not have_tag('a#link-to-adlib-session-destroy')
    end

  end

  describe "(logged in)" do

    before do
      flexmock(self).should_receive(:adlib_logged_in?).and_return(true)
    end

    it "should not display the link to log in" do
      powered_by_adlib.should_not have_tag('a#link-to-adlib-session-new')
    end

    it "should display the link to log out" do
      powered_by_adlib.should have_tag('a#link-to-adlib-session-destroy')
    end

  end

end
