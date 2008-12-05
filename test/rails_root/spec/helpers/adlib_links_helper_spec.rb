require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AdlibHelperSpecHelper  
end

describe AdlibHelper, "adlib_include_tags" do

  it "should render a header tag with all necessary javascripts and stylesheets" do
    adlib_include_tags.length.should > 0
  end

end

describe AdlibHelper, "adlib_link_to" do
end

describe AdlibHelper, "adlib_breadcrumbs" do
end

describe AdlibHelper, "adlib_child_links" do
end

describe AdlibHelper, "adlib_section_links" do
end
