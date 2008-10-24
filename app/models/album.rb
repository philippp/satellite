class Album < ActiveRecord::Base

  belongs_to :user

  has_many :asset_albums, :dependent => :destroy
  has_many :assets, :through => :asset_albums

end
