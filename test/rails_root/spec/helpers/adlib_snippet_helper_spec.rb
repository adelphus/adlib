require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibHelperSpecHelper

  def placeholder_text
    "Lorem ipsum dolor sit amet, consectetur adipisicing elit, " + 
    "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  end
  
  def setup_page_snippet
    @snippet = flexmock(:model, AdlibSnippet)
    flexmock(AdlibSnippet).should_receive(:find_by_page_id_and_slot).with(@adlib_page.id, 'main').and_return(@snippet)
    @snippet.should_receive(:content).and_return('<p>Hello World!</p>')
  end
  
  def setup_ancestor_snippet
    @ancestor = flexmock(:model, AdlibPage)
    @parent = flexmock(:model, AdlibPage)
    @adlib_page.should_receive(:parent).and_return(@parent)
    @parent.should_receive(:parent).and_return(@ancestor)
    @snippet = flexmock(:model, AdlibSnippet)
    flexmock(AdlibSnippet).should_receive(:find_by_page_id_and_slot).with(@adlib_page.id, 'absent').and_return(nil)
    flexmock(AdlibSnippet).should_receive(:find_by_page_id_and_slot).with(@parent.id, 'absent').and_return(nil)
    flexmock(AdlibSnippet).should_receive(:find_by_page_id_and_slot).with(@ancestor.id, 'absent').and_return(@snippet)
    @snippet.should_receive(:content).and_return('<h1>Inherited Content</h1>')
  end
  
end

describe AdlibHelper, "adlib_snippet" do
  include AdlibHelperSpecHelper

  before(:each) do
    @adlib_page = flexmock(:model, AdlibPage)
  end

  it "should render the content of the snippet" do
    setup_page_snippet
    
    adlib_snippet(:main).should == '<div class="adlib-richtext-noedit"><p>Hello World!</p></div>'
  end

  it "should render the content of the snippet as plain text" do
    setup_page_snippet
    
    adlib_snippet(:main, :richtext => false).should == '<div class="adlib-plaintext-noedit">&lt;p&gt;Hello World!&lt;/p&gt;</div>'
  end

  it "should render the content of an ancestor snippet" do
    setup_ancestor_snippet

    adlib_snippet(:absent, :inherit => true).should == '<div class="adlib-richtext-noedit"><h1>Inherited Content</h1></div>'
  end

  it "should render placeholder content" do
    adlib_snippet(:absent).should == '<div class="adlib-richtext-noedit">' + placeholder_text + '</div>'
  end

  describe "(logged in)" do
    
    before(:each) do
      flexmock(self).should_receive(:adlib_logged_in?).and_return(true)
    end

    it "should render the content of the snippet with an edit wrapper" do
      setup_page_snippet
      
      content_re = /<p>Hello World!<\/p>/
      href_re = /\s*?href="\/adlib\/pages\/#{@adlib_page.id}\/snippets\/#{@snippet.id}\/edit\?encoding=richtext"\s*?/
      class_re = /\s*?class="adlib-richtext-edit"\s*?/
      id_re = /\s*?id="snippet_#{@adlib_page.id}_main_edit"\s*?/
      a_re = /<a (#{href_re}|#{class_re}|#{id_re}){3}>EDIT<\/a>/
      class_re = /\s*?class="adlib-richtext"\s*?/
      id_re = /\s*?id="snippet_#{@adlib_page.id}_main"\s*?/
      edit_re = /<div (#{class_re}|#{id_re}){2}>#{a_re}#{content_re}<\/div>/
      
      adlib_snippet(:main).should match(edit_re)
    end

    it "should render the content of the snippet as plain text with an edit wrapper" do
      setup_page_snippet

      content_re = /&lt;p&gt;Hello World!&lt;\/p&gt;/
      href_re = /\s*?href="\/adlib\/pages\/#{@adlib_page.id}\/snippets\/#{@snippet.id}\/edit\?encoding=plaintext"\s*?/
      class_re = /\s*?class="adlib-plaintext-edit"\s*?/
      id_re = /\s*?id="snippet_#{@adlib_page.id}_main_edit"\s*?/
      a_re = /<a (#{href_re}|#{class_re}|#{id_re}){3}>EDIT<\/a>/
      class_re = /\s*?class="adlib-plaintext"\s*?/
      id_re = /\s*?id="snippet_#{@adlib_page.id}_main"\s*?/
      edit_re = /<div (#{class_re}|#{id_re}){2}>#{a_re}#{content_re}<\/div>/

      adlib_snippet(:main, :richtext => false).should match(edit_re)
    end

    it "should render the content of an ancestor snippet with an edit wrapper" do
      setup_ancestor_snippet

      content_re = /<h1>Inherited Content<\/h1>/
      href_re = /\s*?href="\/adlib\/pages\/#{@ancestor.id}\/snippets\/#{@snippet.id}\/edit\?encoding=richtext"\s*?/
      class_re = /\s*?class="adlib-richtext-edit"\s*?/
      id_re = /\s*?id="snippet_#{@ancestor.id}_absent_edit"\s*?/
      a_re = /<a (#{href_re}|#{class_re}|#{id_re}){3}>EDIT<\/a>/
      class_re = /\s*?class="adlib-richtext"\s*?/
      id_re = /\s*?id="snippet_#{@ancestor.id}_absent"\s*?/
      edit_re = /<div (#{class_re}|#{id_re}){2}>#{a_re}#{content_re}<\/div>/
      
      adlib_snippet(:absent, :inherit => true).should match(edit_re)
    end

    it "should render placeholder content with an edit wrapper" do
      slot_re  = /&?slot=absent/
      encoding_re = /&?encoding=richtext/
      params_re = /(#{slot_re}|#{encoding_re}){2}/
      href_re = /\s*?href="\/adlib\/pages\/#{@adlib_page.id}\/snippets\/new\?#{params_re}"\s*?/
      class_re = /\s*?class="adlib-richtext-edit"\s*?/
      id_re = /\s*?id="snippet_#{@adlib_page.id}_absent_edit"\s*?/
      a_re = /<a (#{href_re}|#{class_re}|#{id_re}){3}>EDIT<\/a>/
      class_re = /\s*?class="adlib-richtext"\s*?/
      id_re = /\s*?id="snippet_#{@adlib_page.id}_absent"\s*?/
      edit_re = /<div (#{class_re}|#{id_re}){2}>#{a_re}#{placeholder_text}<\/div>/
      
      adlib_snippet(:absent).should match(edit_re)
    end

  end

end
