require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Photo do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should not create unless asset_id is specified" do
    Photo.create!(@valid_attributes)
  end
end
