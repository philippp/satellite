class Album < ActiveRecord::Base

  belongs_to :user

  has_many :album_assets, :dependent => :destroy
  has_many :assets, :through => :album_assets

end
