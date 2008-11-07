class AdlibSnippet < ActiveRecord::Base
  belongs_to :page, :class_name => 'AdlibPage'
  
  validates_presence_of :page, :slot
  validates_length_of :slot, :maximum => 50, :allow_blank => true
  validates_format_of :slot, :with => /^\w*$/
  validates_uniqueness_of :slot, :scope => :page_id
end
