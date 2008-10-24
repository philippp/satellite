class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer :asset_id
      t.integer :friend_id
      t.integer :x
      t.integer :y

      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
