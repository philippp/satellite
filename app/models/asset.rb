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



  # Assets are descriptive references to binary files. Assets are instantiated in one of three ways:
  # 1. From an HTTP Post object via :uploaded_data. Post a new asset instance from an HTML form and name the file form element "uploaded_data."
  # 2. From a local filename via :uploaded_filename. If you are importing from the local filesystem, specify the full path and filename of the desired file as a string. 
  # 3. From a URL using :uploaded_url, set to the desired file's URL 
  # The properties of Assets are inherited by the specific media classes, such as +Photo+.
class Asset < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true, :counter_cache => :assets_count
  has_many :tags

  has_many :album_assets, :dependent => :destroy
  has_many :albums, :through => :album_assets

  has_attachment :storage => :file_system,
    :thumbnails => { :bigthumb => '500x500>', :mediumthumb => '240x240>', :thumb => '120x120>', :tiny => '50x50>' },
    :max_size => 10.megabytes,
    :path_prefix => "public/assets"
  
  def before_create
    if self.attachable.respond_to?(:all_photos_album) 
      self.albums << self.attachable.all_photos_album unless self.attachable.all_photos_album.nil?
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
  
  def to_param
    return "#{self.id}-#{self.title.gsub(/\W/,'-')}" if self.title
    return self.id.to_s
  end

end
