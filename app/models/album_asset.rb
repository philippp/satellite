class AlbumAsset < ActiveRecord::Base

  belongs_to :asset
  belongs_to :album, :counter_cache => :assets_count

  validates_uniqueness_of :album_id, :scope => :asset_id

end
