require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tag do
  before(:each) do
    @valid_attributes = {
    }
  end


  it "should not create unless asset_id is specified" do
    assert Tag.create({}).id.nil?
  end
  
  
end
