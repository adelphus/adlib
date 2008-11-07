require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibSnippetSpecHelper
  def valid_snippet
    @page = flexmock(:model, AdlibPage)
    AdlibSnippet.new :page => @page, :slot => 'main'
  end
end

describe AdlibSnippet do
  include AdlibSnippetSpecHelper

  before(:each) do
    @snippet = valid_snippet
  end

  it "should be valid" do
    @snippet.should be_valid
  end

  it "should belong to a page" do
    association = AdlibSnippet.reflect_on_association(:page)
    association.macro.should == :belongs_to
    association.class_name.should == 'AdlibPage'
  end
 
  it "should be invalid without a page" do
    @snippet.page = nil
    @snippet.should_not be_valid
    @snippet.should have(1).error_on(:page)
  end

  it "should be invalid without a slot" do
    @snippet.slot = ''
    @snippet.should_not be_valid
    @snippet.should have(1).error_on(:slot)
  end

  it "should be invalid if slot is more than 50 characters" do
    @snippet.slot = 'x'*51
    @snippet.should_not be_valid
    @snippet.should have(1).error_on(:slot)
  end

  it "should be invalid if slot uses non-word characters" do
    ['0Dollar$', '*', 'no-dashes', 'no.dots', 'no spaces'].each do |invalid_slot|
      @snippet.slot = invalid_slot
      @snippet.should_not be_valid
      @snippet.should have(1).error_on(:slot)
    end
  end

  it "should be invalid if slot is not unique within the same page" do
    existing = valid_snippet
    existing.save!
    @snippet.page = existing.page
    @snippet.should_not be_valid
    @snippet.should have(1).error_on(:slot)
  end

  it "should be valid if slot is not-unique but on a different page" do
    existing = valid_snippet
    existing.save!
    @snippet.should be_valid
  end

end
