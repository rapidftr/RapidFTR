require 'spec_helper'

describe Child do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :age => "value for age"
    }
  end

  it "should create a new instance given valid attributes" do
    Child.create!(@valid_attributes)
  end
end
