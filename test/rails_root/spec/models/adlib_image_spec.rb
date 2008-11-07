require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibImageSpecHelper
  def valid_image
    @page = flexmock(:model, AdlibPage)
    AdlibImage.new :page => @page, 
                   :slot => 'main',
                   :file => File.expand_path(File.dirname(__FILE__) + '/../../public/images/sample.jpg')
  end
end

describe AdlibImage do
  include AdlibImageSpecHelper

  before(:each) do
    @image = valid_image
  end

  it "should be valid" do
    @image.should be_valid
  end

  it "should belong to a page" do
    association = AdlibImage.reflect_on_association(:page)
    association.macro.should == :belongs_to
    association.class_name.should == 'AdlibPage'
  end
 
  it "should be valid without a page and slot" do
    @image.page = nil
    @image.slot = ''
    @image.should be_valid
  end

  it "should be invalid without a slot if bound to a page" do
    @image.slot = ''
    @image.should_not be_valid
    @image.should have(1).error_on(:slot)
  end

  it "should be invalid if slot is more than 50 characters" do
    @image.slot = 'x'*51
    @image.should_not be_valid
    @image.should have(1).error_on(:slot)
  end

  it "should be invalid if slot uses non-word characters" do
    ['0Dollar$', '*', 'no-dashes', 'no.dots', 'no spaces'].each do |invalid_slot|
      @image.slot = invalid_slot
      @image.should_not be_valid
      @image.should have(1).error_on(:slot)
    end
  end

  it "should be invalid if slot is not unique within the same page" do
    existing = valid_image
    existing.save!
    @image.page = existing.page
    @image.should_not be_valid
    @image.should have(1).error_on(:slot)
  end

  it "should be valid if slot is not-unique but on a different page" do
    existing = valid_image
    existing.save!
    @image.should be_valid
  end

  it "should be invalid without a content_type" do
    @image.content_type = ''
    @image.should_not be_valid
    @image.should have(1).error_on(:content_type)
  end

  it "should be invalid without a filename" do
    @image.filename = ''
    @image.should_not be_valid
    @image.should have(1).error_on(:filename)
  end

  it "should be invalid without a content_hash" do
    @image.content_hash = ''
    @image.should_not be_valid
    @image.should have(1).error_on(:content_hash)
  end

  it "should be invalid without content" do
    @image.content = ''
    @image.should_not be_valid
    @image.should have(1).error_on(:content)
  end

  it "should be invalid with a non-numeric size" do
    @image.size = 'xyz'
    @image.should_not be_valid
    @image.should have(1).error_on(:size)
  end

  it "should be invalid with a negative size" do
    @image.size = -1
    @image.should_not be_valid
    @image.should have(1).error_on(:size)
  end

  it "should be invalid with a non-numeric width" do
    @image.width = 'xyz'
    @image.should_not be_valid
    @image.should have(1).error_on(:width)
  end

  it "should be invalid with a negative width" do
    @image.width = -1
    @image.should_not be_valid
    @image.should have(1).error_on(:width)
  end

  it "should be invalid with a non-numeric height" do
    @image.height = 'xyz'
    @image.should_not be_valid
    @image.should have(1).error_on(:height)
  end

  it "should be invalid with a negative height" do
    @image.height = -1
    @image.should_not be_valid
    @image.should have(1).error_on(:height)
  end
  
  it "should auto-detect image info" do
    @image.content_type.should == 'image/jpeg'
    @image.filename.should == 'sample.jpg'
    @image.content_hash.should == '778a662f26ee8074803e0eae0448b09a2eb5b95d'
    @image.size.should == 23_655
    @image.width.should == 300
    @image.height.should == 300
  end
  
  it "should accept an uploaded image" do
    uploaded_file = flexmock(:uploaded_file)
    uploaded_file.should_receive(:original_filename).once.and_return('C:\Documents and Settings\John Doe\My Pictures\sample.gif')
    uploaded_file.should_receive(:read).once.and_return(IO.read(File.expand_path(File.dirname(__FILE__) + '/../../public/images/sample.gif')))

    @image.upload = uploaded_file
    @image.content_type.should == 'image/gif'
    @image.filename.should == 'sample.gif'
    @image.content_hash.should == 'a8416b03230678cf97b0e74909fd00ad367a46f1'
    @image.size.should == 38_300
    @image.width.should == 277
    @image.height.should == 300
  end
  
end
