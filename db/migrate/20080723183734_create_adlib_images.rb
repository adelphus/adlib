class CreateAdlibImages < ActiveRecord::Migration
  def self.up
    create_table :adlib_images do |t|
      t.integer :page_id
      t.string :slot
      t.string :content_type
      t.string :filename
      t.string :content_hash
      t.integer :size, :default => 0
      t.integer :width, :default => 0
      t.integer :height, :default => 0
      t.binary :content, :limit => (2**31 - 1)

      t.timestamps
    end
  end

  def self.down
    drop_table :adlib_images
  end
end
