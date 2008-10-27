class AddImportId < ActiveRecord::Migration
  def self.up
    add_column "import_records", "import_id", "integer" 
  end

  def self.down
    remove_column "import_records", "import_id"
  end
end
