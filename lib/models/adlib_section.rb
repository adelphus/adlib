class AdlibSection < ActiveRecord::Base
  has_many :pages, :class_name => 'AdlibPage', :foreign_key => 'section_id', :order => 'lft'

  validates_presence_of :name
  validates_length_of :name, :maximum => 50, :allow_blank => true
  validates_format_of :name, :with => /^\w*$/
  validates_uniqueness_of :name

end
