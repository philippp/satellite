class AlbumAsset < ActiveRecord::Base

  belongs_to :asset
  belongs_to :album

  validates_uniqueness_of :asset_id, :scope => :album_id

end
