class CreateAdlibSnippets < ActiveRecord::Migration
  def self.up
    create_table :adlib_snippets do |t|
      t.integer :page_id
      t.string :slot
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :adlib_snippets
  end
end
