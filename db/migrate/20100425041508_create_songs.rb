class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.references :site
      t.string :url
      t.boolean :active

      t.timestamps
    end

    add_index :songs, :site_id
  end

  def self.down
    drop_table :songs
  end
end
