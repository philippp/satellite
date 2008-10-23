class AssetFields < ActiveRecord::Migration
  def self.up
    add_column :assets, :title, :string
    add_column :assets, :description, :text
  end

  def self.down
    remove_column :assets, :title
    remove_column :assets, :description
  end
end
