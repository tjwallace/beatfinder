class CreatePlaylists < ActiveRecord::Migration
  def self.up
    create_table :playlists do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
    
    add_index :playlists, :user_id
  end

  def self.down
    drop_table :playlists
  end
end
