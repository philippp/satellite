class CreateImportRecords < ActiveRecord::Migration
  def self.up
    create_table :import_records do |t|
      t.string :source
      t.string :sourcekey
      t.string :import_type

      t.timestamps
    end
  end

  def self.down
    drop_table :import_records
  end
end
