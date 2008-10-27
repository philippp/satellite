class CreateFlickrUsers < ActiveRecord::Migration
  def self.up
    create_table :flickr_users do |t|
      t.binary :session

      t.timestamps
    end
  end

  def self.down
    drop_table :flickr_users
  end
end
