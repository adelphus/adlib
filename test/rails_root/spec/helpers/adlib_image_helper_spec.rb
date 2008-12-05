require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibHelperSpecHelper
  
  def setup_page_image
    @image = flexmock(:model, AdlibImage)
    flexmock(AdlibImage).should_receive(:find).with(:first, :select => 'id', 
                                                    :conditions => { :page_id => @adlib_page.id, :slot => :main}
                                                    ).and_return(@image)
  end

  def setup_ancestor_image
    @ancestor = flexmock(:model, AdlibPage)
    @parent = flexmock(:model, AdlibPage)
    @adlib_page.should_receive(:parent).and_return(@parent)
    @parent.should_receive(:parent).and_return(@ancestor)
    @image = flexmock(:model, AdlibImage)
    flexmock(AdlibImage).should_receive(:find).with(:first, :select => 'id', 
                                                    :conditions => { :page_id => @adlib_page.id, :slot => :absent}
                                                    ).and_return(nil)
    flexmock(AdlibImage).should_receive(:find).with(:first, :select => 'id', 
                                                    :conditions => { :page_id => @parent.id, :slot => :absent}
                                                    ).and_return(nil)
    flexmock(AdlibImage).should_receive(:find).with(:first, :select => 'id', 
                                                    :conditions => { :page_id => @ancestor.id, :slot => :absent}
                                                    ).and_return(@image)
  end
  
end

describe AdlibHelper, "adlib_image" do
  include AdlibHelperSpecHelper

  before(:each) do
    @adlib_page = flexmock(:model, AdlibPage)
  end

  it "should render an img tag for the image content" do
    setup_page_image
    
    src_re = /\s*?src="\/adlib\/pages\/#{@adlib_page.id}\/images\/#{@image.id}"\s*?/
    alt_re = /\s*?alt="Main"\s*?/
    img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
    a_re = /<a class="adlib-image-noedit">#{img_re}<\/a>/
    
    adlib_image(:main).should match(a_re)
  end

  it "should render an img tag for the ancestor image content" do
    setup_ancestor_image

    src_re = /\s*?src="\/adlib\/pages\/#{@ancestor.id}\/images\/#{@image.id}"\s*?/
    alt_re = /\s*?alt="Absent"\s*?/
    img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
    a_re = /<a class="adlib-image-noedit">#{img_re}<\/a>/

    adlib_image(:absent, :inherit => true).should match(a_re)
  end

  it "should render an img tag with placeholder content for the image" do
    src_re = /\s*?src="\/adlib\/pages\/#{@adlib_page.id}\/images\/0"\s*?/
    alt_re = /\s*?alt="Absent"\s*?/
    img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
    a_re = /<a class="adlib-image-noedit">#{img_re}<\/a>/

    adlib_image(:absent).should match(a_re)
  end

  it "should render an img tag for the image content with layout" do    setup_page_image
    
    layout_re = /&?layout=grayscale%2Cresize_and_crop/
    width_re  = /&?width=80/
    height_re = /&?height=100/
    params_re = /(#{layout_re}|#{width_re}|#{height_re}){3}/
    src_re = /\s*?src="\/adlib\/pages\/#{@adlib_page.id}\/images\/#{@image.id}\?#{params_re}"\s*?/
    alt_re = /\s*?alt="Main"\s*?/
    img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
    a_re = /<a class="adlib-image-noedit">#{img_re}<\/a>/
    
    adlib_image(:main, :layout => [:grayscale, :resize_and_crop], :width => 80, :height => 100).should match(a_re)
  end

  describe "(logged in)" do

    before(:each) do
      flexmock(self).should_receive(:adlib_logged_in?).and_return(true)
    end
  
    it "should render an img tag for the image content with an edit wrapper" do
      setup_page_image

      src_re = /\s*?src="\/adlib\/pages\/#{@adlib_page.id}\/images\/#{@image.id}"\s*?/
      alt_re = /\s*?alt="Main"\s*?/
      img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
      href_re = /\s*?href="\/adlib\/pages\/#{@adlib_page.id}\/images\/#{@image.id}\/edit"\s*?/
      class_re = /\s*?class="adlib-image"\s*?/
      span_re = /<span class="adlib-image-edit">EDIT<\/span>/
      edit_re = /<a (#{href_re}|#{class_re}){2}>#{span_re}#{img_re}<\/a>/

      adlib_image(:main).should match(edit_re)
    end

    it "should render an img tag for the ancestor image content with an edit wrapper" do
      setup_ancestor_image

      src_re = /\s*?src="\/adlib\/pages\/#{@ancestor.id}\/images\/#{@image.id}"\s*?/
      alt_re = /\s*?alt="Absent"\s*?/
      img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
      href_re = /\s*?href="\/adlib\/pages\/#{@ancestor.id}\/images\/#{@image.id}\/edit"\s*?/
      class_re = /\s*?class="adlib-image"\s*?/
      span_re = /<span class="adlib-image-edit">EDIT<\/span>/
      edit_re = /<a (#{href_re}|#{class_re}){2}>#{span_re}#{img_re}<\/a>/

      adlib_image(:absent, :inherit => true).should match(edit_re)
    end

    it "should render an img tag with placeholder content for the image with an edit wrapper" do
      src_re = /\s*?src="\/adlib\/pages\/#{@adlib_page.id}\/images\/0"\s*?/
      alt_re = /\s*?alt="Absent"\s*?/
      img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
      href_re = /\s*?href="\/adlib\/pages\/#{@adlib_page.id}\/images\/new\?slot=absent"\s*?/
      class_re = /\s*?class="adlib-image"\s*?/
      span_re = /<span class="adlib-image-edit">EDIT<\/span>/
      edit_re = /<a (#{href_re}|#{class_re}){2}>#{span_re}#{img_re}<\/a>/

      adlib_image(:absent).should match(edit_re)
    end

    it "should render an img tag for the image content with formatting instructions with an edit wrapper" do      setup_page_image
      
      layout_re = /&?layout=grayscale%2Cresize_and_crop/
      width_re  = /&?width=80/
      height_re = /&?height=100/
      params_re = /(#{layout_re}|#{width_re}|#{height_re}){3}/
      src_re = /\s*?src="\/adlib\/pages\/#{@adlib_page.id}\/images\/#{@image.id}\?#{params_re}"\s*?/
      alt_re = /\s*?alt="Main"\s*?/
      img_re = /<img (#{src_re}|#{alt_re}){2} \/>/
      href_re = /\s*?href="\/adlib\/pages\/#{@adlib_page.id}\/images\/#{@image.id}\/edit\?#{params_re}"\s*?/
      class_re = /\s*?class="adlib-image"\s*?/
      span_re = /<span class="adlib-image-edit">EDIT<\/span>/
      edit_re = /<a (#{href_re}|#{class_re}){2}>#{span_re}#{img_re}<\/a>/
      
      adlib_image(:main, :layout => [:grayscale, :resize_and_crop], :width => 80, :height => 100).should match(edit_re)
    end

  end

end

