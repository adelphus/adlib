class AdlibImage < ActiveRecord::Base
  belongs_to :page, :class_name => 'AdlibPage'
  
  validates_presence_of :slot, :if => :page
  validates_length_of :slot, :maximum => 50, :allow_blank => true
  validates_format_of :slot, :with => /^\w*$/
  validates_uniqueness_of :slot, :scope => :page_id, :if => :page

  validates_presence_of :content_type, :filename, :content_hash, :content
  
  validates_numericality_of :size, :integer_only => true, :greater_than_or_equal_to => 0
  validates_numericality_of :width, :integer_only => true, :greater_than_or_equal_to => 0
  validates_numericality_of :height, :integer_only => true, :greater_than_or_equal_to => 0
  
  def file=(file)
    img = Magick::Image::ping(file).first
    data = IO.read(file)

    set_image_properties(img, data)
  end
  
  def upload=(upload)
    data = upload.read
    img = Magick::Image::from_blob(data).first
    
    set_image_properties(img, data)

    self.filename = sanitize_uploaded_filename(upload.original_filename)
  end
  
  private
  
    def set_image_properties(img, data)
      self.content_type = mime_type_from_rmagick_format(img.format)
      self.filename = File.basename(img.filename)
      self.content_hash = Digest::SHA1.hexdigest(data)
      self.content = data

      self.size = img.filesize
      self.width = img.columns
      self.height = img.rows    
    end
  
    def mime_type_from_rmagick_format(format)
      case format
        when 'GIF':   'image/gif'
        when 'JPEG':  'image/jpeg'
        when 'PNG':   'image/png'
        when 'PNG8':  'image/png'
        when 'PNG24': 'image/png'
        when 'PNG32': 'image/png'
        else          'image/unknown'      
      end
    end
    
    def sanitize_uploaded_filename(filename)
      File.basename(filename.gsub(/\\/, '/')).gsub /[^\w\.\_]/, '_'
    end
  
end
