require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibUserSpecHelper
  def valid_user
    AdlibUser.new :username => 'johndoe',
                  :password => 'password'
  end
end

describe AdlibUser do
  include AdlibUserSpecHelper

  before(:each) do
    @user = valid_user
  end
  
  it "should be valid" do
    @user.should be_valid
  end

  it "should be invalid without a username" do
    @user.username = ''
    @user.should_not be_valid
    @user.should have(1).error_on(:username)
  end

  it "should be invalid if username is more than 50 characters" do
    @user.username = 'x'*51
    @user.should_not be_valid
    @user.should have(1).error_on(:username)
  end

  it "should be invalid if username uses non-word characters" do
    ['0Dollar$', '*', 'no-dashes', 'no.dots', 'no spaces'].each do |invalid_name|
      @user.username = invalid_name
      @user.should_not be_valid
      @user.should have(1).error_on(:username)
    end
  end

  it "should be invalid if username is not unique" do
    @user.save!
    @user = valid_user
    @user.should_not be_valid
    @user.should have(1).error_on(:username)
  end

  it "should be invalid without a password" do
    @user.password = ''
    @user.should_not be_valid
    @user.should have(1).error_on(:password)
  end

  it "should change the password salt and hash when the password is set" do
    salt = @user.password_salt
    hash = @user.password_hash    
    @user.password = 'password'
    @user.password_salt.should_not == salt
    @user.password_hash.should_not == hash
  end

  it "should not show a plain text password" do
    @user.password.should be_nil
  end

  it "should be authenticated when given the correct password" do
    @user.should be_authenticated('password')
  end

  it "should not be authenticated when given a bad password" do
    @user.should_not be_authenticated('wrong')
  end

  it "should set an error when given a bad password" do
    @user.authenticated?('wrong')
    @user.errors.should_not be_empty
  end

  it "should not set an error when given a correct password" do
    @user.authenticated?('password')
    @user.errors.should be_empty
  end
  
end
