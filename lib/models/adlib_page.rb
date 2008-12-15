class AdlibPage < ActiveRecord::Base
  acts_as_nested_set
  belongs_to :shortcut, :class_name => 'AdlibPage'

  validates_presence_of :name
  validates_presence_of :layout, :if => :slug?
  validates_length_of :name, :maximum => 250, :allow_blank => true
  validates_length_of :title, :maximum => 250, :allow_blank => true
  validates_length_of :layout, :maximum => 50, :allow_blank => true
  validates_length_of :slug, :maximum => 50, :allow_blank => true
  validates_format_of :slug, :with => /^(\w*\/)?$/
  validates_length_of :url, :maximum => 250, :allow_blank => true
  
  validate :ensure_presence_of_slug_or_url_or_shortcut
  validate :ensure_uniqueness_of_slug_amongst_siblings
  validate :ensure_parent_uses_slug
  validate :ensure_format_of_url
  validate :ensure_shortcut_points_to_slug_page

  def full_slug
    self_and_ancestors.collect { |page| page.slug }.join
  end

  class << self
    def find_by_path(path)
      page = find_by_slug('/') or raise ActiveRecord::RecordNotFound
      path.each do |slug|
        page = find_by_parent_id_and_slug(page.id, slug + '/')
        raise ActiveRecord::RecordNotFound if page.nil?
      end
      page
    end
    
    def order(ids)
      return unless ids.length > 1
      ids.inject do |previous, id|
        AdlibPage.find(id).move_to_right_of previous
      end
    end
  end
  
  private

    def ensure_presence_of_slug_or_url_or_shortcut
      errors.add_to_base "Slug, URL and Shortcut can't all be blank" if slug.blank? and url.blank? and shortcut.blank?
    end

    def ensure_uniqueness_of_slug_amongst_siblings
      unless slug.blank?
        errors.add :slug, 'has already been taken' if siblings.any? {|page| page.slug == slug}
      end
    end

    def ensure_parent_uses_slug
      unless parent.nil?
        errors.add_to_base 'Page cannot be the child of a non-slug page' if parent.slug.blank?
      end
    end

    def ensure_format_of_url
      unless url.blank?
        uri = URI.parse(url)
        raise URI::InvalidURIError unless uri.class == URI::HTTP || uri.class == URI::HTTPS
      end
    rescue URI::InvalidURIError
      errors.add :url, 'is invalid'
    end

    def ensure_shortcut_points_to_slug_page
      unless shortcut.nil?
        errors.add :shortcut, 'is invalid' unless shortcut.valid? and not shortcut.slug.blank?
      end
    end
  
end
