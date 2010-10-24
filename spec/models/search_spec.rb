require 'spec_helper'

describe Search do
  
  it "should not be valid if it has more than 150 chars" do
    search = Search.new("A"*151)
    search.valid?.should be_false
  end
  
end