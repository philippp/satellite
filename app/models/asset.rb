# == Schema Information
# Schema version: 20081004012912
#
# Table name: assets
#
#  id              :integer(4)    not null, primary key
#  filename        :string(255)
#  width           :integer(4)
#  height          :integer(4)
#  content_type    :string(255)
#  size            :integer(4)
#  attachable_type :string(255)
#  attachable_id   :integer(4)
#  updated_at      :datetime
#  created_at      :datetime
#  thumbnail       :string(255)
#  parent_id       :integer(4)
#

class Asset < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true, :counter_cache => :assets_count
  has_many :tags

  has_many :asset_albums, :dependent => :destroy, :include => [:asset => [:datafile]]
  has_many :albums, :through => :asset_albums

  has_attachment :storage => :file_system,
    :thumbnails => { :bigthumb => '400>', :thumb => '120>', :tiny => '50>' },
    :max_size => 5.megabytes,
    :path_prefix => "public/assets"

  # this url will change every time the datafile is rotated,
  # tested in FF2, 3, IE, Safari
  def cachebusted_filename(size, stamp = "%I%M%S")
    self.public_filename(size) + "?t=#{self.updated_at.strftime(stamp)}"
  end

  # stub till we have comments
  def comments_count
    0
  end

  def title_abr(size = 15)
    if self.title and self.title.length > size
      "#{self.title[0,size]}..."
    else
      self.title || ""
    end
  end

end
