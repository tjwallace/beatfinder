class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name
      t.boolean :visible
      t.boolean :scanable
      t.string :url
      t.string :resource_url

      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
