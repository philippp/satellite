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

  has_many :album_assets, :dependent => :destroy, :include => [:asset => [:datafile]]
  has_many :albums, :through => :album_assets

  has_attachment :storage => :file_system,
    :thumbnails => { :bigthumb => '500x500>', :mediumthumb => '240x240>', :thumb => '120x120>', :tiny => '50x50>' },
    :max_size => 10.megabytes,
    :path_prefix => "public/assets"

  def before_create
    if self.attachable.respond_to?(:all_photos_album)
      self.albums << self.attachable.all_photos_album.assets
    end
  end

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
