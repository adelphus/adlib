class CreateAdlibUsers < ActiveRecord::Migration
  def self.up
    create_table :adlib_users do |t|
      t.string :username
      t.string :password_hash
      t.string :password_salt

      t.timestamps
    end
  end

  def self.down
    drop_table :adlib_users
  end
end
