class CreateAdlibSections < ActiveRecord::Migration
  def self.up
    create_table :adlib_sections do |t|
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :adlib_sections
  end
end
