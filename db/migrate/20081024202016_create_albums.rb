class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.integer :assets_count, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
