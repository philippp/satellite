class CreateAlbumAssets < ActiveRecord::Migration
  def self.up
    create_table :album_assets do |t|
      t.integer :album_id
      t.integer :asset_id

      t.timestamps
    end
    add_index :album_assets, :album_id
    add_index :album_assets, :asset_id
  end

  def self.down
    drop_table :album_assets
  end
end
