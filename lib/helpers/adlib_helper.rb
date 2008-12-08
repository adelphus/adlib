module AdlibHelper
  
  def adlib_logged_in?
    !session[:adlib_user_id].nil?
  end
  
  def adlib_user
    @adlib_user ||= AdlibUser.find_by_id(session[:adlib_user_id])
  end

  def adlib_include_tags
    stylesheets = %w{ jquery-ui-themeroller adlib-0.1.0 }
    javascripts = %w{ tiny_mce/tiny_mce jquery-1.2.6.min jquery-ui-personalized-1.6rc2.min adlib-0.1.0 }

    stylesheets.collect { |name| "<link href='/adlib/stylesheets/#{name}.css' rel='stylesheet' type='text/css'>" }.join +
    javascripts.collect { |name| "<script language='javascript' src='/adlib/javascripts/#{name}.js'></script>" }.join
  end

  def adlib_page_toolbar
    return '' unless adlib_logged_in?
    content = link_to 'EDIT PAGE SETTINGS', "#{edit_adlib_page_path(@adlib_page)}", :id => 'adlib_link_to_page_edit', :class => 'adlib-modal-dialog'
    content_tag :div, content, :id => 'adlib-page-toolbar'
  end

  def adlib_powered_by
    adelphus_link = link_to 'Adelphus', 'http://www.adelphus.com/', :target => '_blank'

    if adlib_logged_in?
      adlib_link = ' | '
      adlib_link += link_to 'Logout', '/adlib/session', :id => 'adlib_link_to_session_destroy', :method => :delete
    else
      adlib_link = link_to 'Adlib', '/adlib/session/new', :id => 'adlib_link_to_session_new', :class => 'adlib-modal-dialog'
    end
    
    content = "Powered by #{adelphus_link} #{adlib_link}"
    content_tag :div, content, :id => 'adlib-powered-by'
  end
  
  def adlib_link_to(page = @adlib_page)
    options = {}
    href = if page.slug?
             page.full_slug
           elsif page.url?
             options[:target] = '_blank'
             page.url
           else
             page.shortcut.full_slug
           end
    
    link_to(page.name, href, options)
  end

  def adlib_breadcrumbs(options = {})
    page = options[:adlib_page] || @adlib_page
    
    page.ancestors.collect do |ancestor|
      adlib_link_to ancestor
    end    
  end

  def adlib_child_links(options = {})
    page = options[:adlib_page] || @adlib_page

    page.children.collect do |child|
      adlib_link_to child
    end
  end

  def adlib_section_links(section_name)
    section = AdlibSection.find_by_name(section_name.to_s)
    section.pages.collect do |page|
      adlib_link_to page
    end
  end
  
  def adlib_snippet(slot, options = {})
    page = options[:adlib_page] || @adlib_page
    richtext = options[:richtext].nil? ? true : options[:richtext]
    
    page, snippet = find_adlib_page_and_snippet_by_self_or_ancestor_page_and_slot(page, slot, options[:inherit])

    content = snippet ? snippet.content : snippet_placeholder_text
    content = h(content) unless richtext
    
    if adlib_logged_in?
      snippet_edit_wrapper(content, richtext, page, snippet, slot)
    else
      encoding = richtext ? 'richtext' : 'plaintext'
      content_tag :div, content, :class => "adlib-#{encoding}-noedit"
    end
  end
  
  def adlib_image(slot, options = {})
    page = options[:adlib_page] || @adlib_page
    layout = extract_layout(options)

    page, image_id = find_adlib_page_and_image_id_by_self_or_ancestor_page_and_slot(page, slot, options[:inherit])

    path_args = [page.id, image_id || 0]
    path_args << layout if layout
    content = tag(:img, { :src => adlib_page_image_path(*path_args), :alt => slot.to_s.humanize }, false, false)

    if adlib_logged_in?
      image_edit_wrapper(content, image_id, path_args, slot)
    else
      content_tag :a, content, :class => 'adlib-image-noedit'
    end
  end

  private

    def find_adlib_page_and_snippet_by_ancestor_page_and_slot(page, slot)
      snippet = nil
      while !snippet and page = page.parent
        snippet = AdlibSnippet.find_by_page_id_and_slot(page.id, slot)
      end
      [page, snippet]
    end

    def find_adlib_page_and_snippet_by_self_or_ancestor_page_and_slot(page, slot, inherit)
      snippet = AdlibSnippet.find_by_page_id_and_slot(page.id, slot.to_s)
      if !snippet and inherit
        find_adlib_page_and_snippet_by_ancestor_page_and_slot(page, slot.to_s)
      else
        [page, snippet]
      end
    end  

    def snippet_placeholder_text
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit, " +
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    end

    def find_adlib_image_id_by_page_and_slot(page, slot)
      image = AdlibImage.find(:first, :select => 'id', :conditions => { :page_id => page.id, :slot => slot })
      image ? image.id : nil
    end
    
    def find_adlib_page_and_image_id_by_ancestor_page_and_slot(page, slot)
      image_id = nil
      while !image_id and page = page.parent
        image_id = find_adlib_image_id_by_page_and_slot(page, slot)
      end 
      [page, image_id]
    end
    
    def find_adlib_page_and_image_id_by_self_or_ancestor_page_and_slot(page, slot, inherit)
      image_id = find_adlib_image_id_by_page_and_slot(page, slot)
      if !image_id and inherit
        find_adlib_page_and_image_id_by_ancestor_page_and_slot(page, slot)
      else
        [page, image_id]
      end
    end
    
    def extract_layout(options)
      options[:layout] && options.except(:page, :inherit).update(:layout => options[:layout].join(','))  
    end
    
    def image_edit_wrapper(content, image_id, path_args, slot)
      content = content_tag(:span, 'EDIT', :class => 'adlib-image-edit') + content
      if image_id
        href = edit_adlib_page_image_path(*path_args)
      else
        path_args.delete_at 1
        path_args << { :slot => slot }
        href = new_adlib_page_image_path(*path_args)
      end
      content = link_to(content, href, :class => 'adlib-image')
    end

    def snippet_edit_wrapper(content, richtext, page, snippet, slot)
      encoding = richtext ? 'richtext' : 'plaintext'
      if snippet
        href = edit_adlib_page_snippet_path(page.id, snippet.id, :encoding => encoding)
      else
        href = new_adlib_page_snippet_path(page.id, :slot => slot, :encoding => encoding)
      end
      html_id = "snippet_#{page.id}_#{slot}"
      content = link_to('EDIT', href, :id => "#{html_id}_edit", :class => "adlib-#{encoding}-edit") + content
      content = content_tag(:div, content, :id => html_id, :class => "adlib-#{encoding}")
    end

end
