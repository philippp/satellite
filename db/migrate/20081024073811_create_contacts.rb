class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.text :point
      t.string :source
      t.integer :friend_id
      t.string :contact_type

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
