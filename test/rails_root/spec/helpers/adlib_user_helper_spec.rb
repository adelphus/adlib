require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdlibHelper, "adlib_logged_in?" do

  it "should return false if not logged in" do
    adlib_logged_in?.should == false
  end
  
  it "should return the current logged in adlib user" do
    user = flexmock(:model, AdlibUser)
    flexmock(AdlibUser).should_receive(:find_by_id).with(user.id).and_return(user)
    session[:adlib_user_id] = user.id
          
    adlib_logged_in?.should == true
  end

end

describe AdlibHelper, "adlib_user" do

  it "should return nil if not logged in" do
    adlib_user.should be_nil
  end
  
  it "should return the current logged in adlib user" do
    user = flexmock(:model, AdlibUser)
    flexmock(AdlibUser).should_receive(:find_by_id).with(user.id).and_return(user)
    session[:adlib_user_id] = user.id
          
    adlib_user.should == user
  end

end
