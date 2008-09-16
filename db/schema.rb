# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define() do

  create_table "assets", :force => true do |t|
    t.column "filename",        :string
    t.column "width",           :integer
    t.column "height",          :integer
    t.column "content_type",    :string
    t.column "size",            :integer
    t.column "attachable_type", :string
    t.column "attachable_id",   :integer
    t.column "updated_at",      :datetime
    t.column "created_at",      :datetime
    t.column "thumbnail",       :string
    t.column "parent_id",       :integer
  end

  create_table "schema_migrations", :id => false, :force => true do |t|
    t.column "version", :string, :default => "", :null => false
  end

  add_index "schema_migrations", ["version"], :name => "unique_schema_migrations", :unique => true

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "last_login_at",             :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
    t.column "visits_count",              :integer,                :default => 0
    t.column "time_zone",                 :string,                 :default => "Etc/UTC"
    t.column "permalink",                 :string
  end

end
