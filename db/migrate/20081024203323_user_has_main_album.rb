class UserHasMainAlbum < ActiveRecord::Migration
  def self.up
    add_column :users, :all_photos_album_id, :integer
  end

  def self.down
    remove_column :users, :all_photos_album_id
  end
end
