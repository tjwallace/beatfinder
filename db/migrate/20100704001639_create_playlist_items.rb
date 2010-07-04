class CreatePlaylistItems < ActiveRecord::Migration
  def self.up
    create_table :playlist_items do |t|
      t.integer :song_id
      t.integer :playlist_id
      t.integer :position

      t.timestamps
    end
    
    add_index :playlist_items, :song_id
    add_index :playlist_items, :playlist_id
    add_index :playlist_items, [:playlist_id, :position]
  end

  def self.down
    drop_table :playlist_items
  end
end
