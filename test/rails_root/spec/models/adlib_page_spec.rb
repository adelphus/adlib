require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibPageSpecHelper
  def valid_page
    AdlibPage.new :name   => 'The Page Name',
                  :layout => 'default',
                  :slug   => 'bar/'
  end

  def valid_url_page
    AdlibPage.new :name => 'The Page Name',
                  :url  => 'http://www.google.com/'
  end

  def valid_shortcut_page
    AdlibPage.new :name     => 'The Page Name',
                  :shortcut => valid_page
  end
  
  def valid_page_with_ancestors
    root = AdlibPage.create!(:name => 'Root', :layout => 'default', :slug => '/')
    foo = AdlibPage.create!(:name => 'Foo', :layout => 'default', :slug => 'foo/')
    foo.move_to_child_of root
    bar = AdlibPage.create!(:name => 'Bar', :layout => 'default', :slug => 'bar/')
    bar.move_to_child_of foo
    baz = AdlibPage.create!(:name => 'Baz', :layout => 'default', :slug => 'baz/')
    baz.move_to_child_of bar
    baz
  end
end

describe AdlibPage do
  include AdlibPageSpecHelper

  before(:each) do
    #@root = AdlibPage.create!(:name => 'Root Page', :slug => '/', :layout => 'default')
    #@upper = AdlibPage.create!(:name => 'Upper Page', :slug => 'foo/', :layout => 'default')
    #@upper.move_to_child_of @root
    @page = valid_page
  end

  it "should be valid" do
    @page.should be_valid
  end

  it "should be valid as a url" do
    valid_url_page.should be_valid
  end

  it "should be valid as a shortcut" do
    valid_shortcut_page.should be_valid
  end
  
  it "should act like a nested set" do
    [:root, :roots, :level, :ancestors, :self_and_ancestors, :siblings,
     :self_and_siblings, :parent, :children, :all_children, :full_set, 
     :move_to_left_of, :move_to_right_of, :move_to_child_of].each do |method_name|
      @page.should respond_to(method_name)
    end
  end
  
  it "should belong to shortcut" do
    association = AdlibPage.reflect_on_association(:shortcut)
    association.macro.should == :belongs_to
    association.class_name.should == 'AdlibPage'
  end
  
  it "should be invalid without a name" do
    @page.name = ''
    @page.should_not be_valid
    @page.should have(1).error_on(:name)
  end

  it "should be invalid without a layout" do
    @page.layout = ''
    @page.should_not be_valid
    @page.should have(1).error_on(:layout)
  end

  it "should be invalid if name is more than 250 characters" do
    @page.name = 'x'*251
    @page.should_not be_valid
    @page.should have(1).error_on(:name)
  end

  it "should be invalid if title is more than 250 characters" do
    @page.title = 'x'*251
    @page.should_not be_valid
    @page.should have(1).error_on(:title)
  end

  it "should be invalid if layout is more than 50 characters" do
    @page.layout = 'x'*51
    @page.should_not be_valid
    @page.should have(1).error_on(:layout)
  end
  
  it "should be invalid if slug is more than 50 characters" do
    @page.slug = 'x'*50 + '/'
    @page.should_not be_valid
    @page.should have(1).error_on(:slug)
  end
  
  it "should be invalid if slug uses non-word characters" do
    ['0Dollar$/', '*/', 'no-dashes/', 'no.dots/', 'no spaces/'].each do |invalid_slug|
      @page.slug = invalid_slug
      @page.should_not be_valid
      @page.should have(1).error_on(:slug)
    end
  end
  
  it "should be invalid if slug does not end with a slash" do
    @page.slug = 'foobar'
    @page.should_not be_valid
    @page.should have(1).error_on(:slug)
  end

  it "should be invalid if url is more than 250 characters" do
    @page.url = 'http://www.example.org/' + 'foo/'*56 + 'barz'
    @page.should_not be_valid
    @page.should have(1).error_on(:url)
  end

  it "should be invalid without a slug, url, or shortcut" do
    @page.slug = ''
    @page.should_not be_valid
    @page.should have(1).error
  end

  it "should be invalid if slug is not unique amongst sibling pages" do
    parent = valid_page
    parent.save!
    sibling = valid_page
    sibling.save!
    sibling.move_to_child_of parent
    @page.save!
    @page.move_to_child_of parent
    @page.should_not be_valid
    @page.should have(1).error
  end

  it "should be valid if slug is unique amongst sibling pages but not unique globally" do
    parent = valid_page
    parent.save!
    @page.save!
    @page.move_to_child_of parent
    @page.move_to_child_of parent
    @page.should be_valid
  end

  it "should be invalid if parent is not using a slug" do
    parent = valid_url_page
    parent.save!
    @page.save!
    @page.move_to_child_of parent
    @page.should_not be_valid
    @page.should have(1).error
  end

  it "should be invalid if url is not in a valid format" do
    ['###', 'jim@email.org', 'ftp://ftp.funet.fi/', 'www.noschema.com'].each do |invalid_url|
      @page.url = invalid_url
      @page.should_not be_valid
      @page.should have(1).error_on(:url)
    end
  end

  it "should be invalid if shortcut is not pointing to a valid slug page" do
    @page.shortcut = valid_url_page
    @page.should_not be_valid
    @page.should have(1).error_on(:shortcut)
  end

  it "should be findable by path" do
    @page = valid_page_with_ancestors
    AdlibPage.find_by_path(%w{ foo bar baz }).should == @page
  end

  it "should raise RecordNotFound when nothing is found by path" do
    lambda do
      AdlibPage.find_by_path(%w{ foo bar baz })
    end.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should know how to give a full slug" do
    @page = valid_page_with_ancestors
    @page.save!
    @page.full_slug.should == '/foo/bar/baz/'
  end

end
