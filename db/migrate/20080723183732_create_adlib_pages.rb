class CreateAdlibPages < ActiveRecord::Migration
  def self.up
    create_table :adlib_pages do |t|
      t.string :name
      t.string :title
      t.string :layout
      t.string :slug
      t.string :url
      t.integer :shortcut_id
      t.integer :section_id
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt

      t.timestamps
    end
  end

  def self.down
    drop_table :adlib_pages
  end
end
