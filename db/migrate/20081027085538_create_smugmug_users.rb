class CreateSmugmugUsers < ActiveRecord::Migration
  def self.up
    create_table :smugmug_users do |t|
      t.string :user_id
      t.string :pw_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :smugmug_users
  end
end
