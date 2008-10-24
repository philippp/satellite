require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Album do
  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :desciption => "value for desciption",
      :user_id => "1",
      :asset_count => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    Album.create!(@valid_attributes)
  end
end
