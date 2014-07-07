require 'spec_helper'

describe Search, :type => :model do

  it "should be valid if search contains special characters" do
    search = Search.new("r*")
    expect(search.valid?).to be_truthy
    expect(search.errors.on(:query)).to be nil
  end

  it "should not be valid if search has no query" do
    search = Search.new("")
    expect(search.valid?).to be_falsey
    expect(search.errors.on(:query)).to eq("can't be empty")

    search = Search.new("child")
    expect(search.valid?).to be_truthy
  end

  it "should not be valid if it has more than 150 chars" do
    search = Search.new("A"*151)
    expect(search.valid?).to be_falsey
    expect(search.errors.on(:query)).to eq("is invalid")
  end

  it "should strip spaces" do
     search = Search.new(" roger ")
     expect(search.query).to eq("roger")
  end

  it "should validate empty without special characters" do
    search = Search.new("@")
    expect(search.query).to eq("")
    expect(search.valid?).to be_falsey
    expect(search.errors.on(:query)).to eq("can't be empty")
  end

end
