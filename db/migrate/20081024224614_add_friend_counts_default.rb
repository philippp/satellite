class AddFriendCountsDefault < ActiveRecord::Migration

  def self.up
    change_column_default(:friends, :tags_count, 0)
    change_column_default(:friends, :contacts_count, 0)
    
    Friend.find(:all, :conditions => { :tags_count => nil }).each{ |f| f.tags_count = 0; f.save }
    Friend.find(:all, :conditions => { :contacts_count => nil }).each{ |f| f.contacts_count = 0; f.save }
  end

  def self.down
  end

  
end
