require 'spec_helper'

describe Search do

  it "should be valid if search contains special characters" do
    search = Search.new("r*")
    search.valid?.should be_true
    search.errors.on(:query).should be nil
  end

  it "should not be valid if search has no query" do
    search = Search.new("")
    search.valid?.should be_false
    search.errors.on(:query).should == "can't be empty"

    search = Search.new("child")
    search.valid?.should be_true
  end

  it "should not be valid if it has more than 150 chars" do
    search = Search.new("A"*151)
    search.valid?.should be_false
    search.errors.on(:query).should == "is invalid"
  end

  it "should strip spaces" do
     search = Search.new(" roger ")
     search.query.should == "roger"
  end

  it "should validate empty without special characters" do
    search = Search.new("@")
    search.query.should == ""
    search.valid?.should be_false
    search.errors.on(:query).should == "can't be empty"
  end

end
