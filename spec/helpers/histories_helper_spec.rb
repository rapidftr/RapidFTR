require 'spec_helper'

describe HistoriesHelper do
  
  it "should have change wording when 'from' and 'to' values exist" do
    view = Object.new
    view.extend(HistoriesHelper)
    
    view.history_wording("London", "New York").should == "changed from London to New York"
  end

  it "should have initial wording when 'from' value is empty" do
    view = Object.new
    view.extend(HistoriesHelper)
    
    view.history_wording("", "New York").should == "initially set to New York"
  end

  it "should have initial wording when 'from' value is nil" do
    view = Object.new
    view.extend(HistoriesHelper)
    
    view.history_wording(nil, "New York").should == "initially set to New York"
  end
end