class Tag < ActiveRecord::Base

  belongs_to :friend
  belongs_to :asset

  validates_presence_of :asset_id
  validates_uniqueness_of :asset_id, :scope => :friend_id, :if => :friend_id

  def to_json(*a)
    { :x => self.x,
      :y => self.y, 
      :name => self.friend.name,
      :id => self.id }.to_json(*a)
  end
  
end
