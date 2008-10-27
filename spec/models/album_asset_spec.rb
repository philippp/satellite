require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AlbumAsset do
  before(:each) do
    @valid_attributes = {
      :album_id => 1,
      :asset_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    AlbumAsset.create!(@valid_attributes)
  end
end
