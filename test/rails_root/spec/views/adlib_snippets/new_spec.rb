require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/adlib/snippets/new' do

  before(:each) do
    @controller.view_paths = File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/views')
    @snippet = flexmock(:model, AdlibSnippet)
    @snippet.errors.should_receive(:empty?).and_return(true).by_default
    @snippet.should_receive(:slot).and_return(nil).by_default
    @snippet.should_receive(:content).and_return(nil).by_default
    assigns[:adlib_snippet] = @snippet
  end
  
  it "should display an edit form with slot and content fields" do
    render '/adlib_snippets/new'
    
    response.should have_tag('input[name=?]', 'adlib_snippet[slot]')
    response.should have_tag('textarea[name=?]', 'adlib_snippet[content]')
    response.should have_tag('input[value=?]', 'Save Changes')
  end

  it "should display an error message after an unsuccessful save" do
    @snippet.errors.should_receive(:empty?).and_return(false)
    @snippet.errors.should_receive(:on_base).and_return('Unexpected error.')

    render '/adlib_snippets/new'
    
    response.should have_tag('.error', 'Unexpected error.')
  end

  it "should not display an error message when no save was attempted" do
    render '/adlib_snippets/new'
    
    response.should_not have_tag('.error')
  end

end
