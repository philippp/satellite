class Tag < ActiveRecord::Base

  belongs_to :friend
  belongs_to :asset

  validates_presence_of :friend_id
  validates_presence_of :asset_id
  validates_uniqueness_of :asset_id, :scope => :friend_id, :if => :friend_id

  # Includes friend name and ID for UI friend interaction
  def to_json(*a)
    { :x => self.x,
      :y => self.y, 
      :name => self.friend.name,
      :friend_id => self.friend.id,
      :id => self.id }.to_json(*a)
  end
  
  def after_create
    #counter cache doesn't change 'updated_at'
    sql = "UPDATE `friends` SET `tags_count` = `tags_count` + 1, updated_at = '#{Time.now.utc.to_s(:db)}' WHERE id = #{self.friend_id}"
    ActiveRecord::Base.connection.execute(sql)
  end
  
end
