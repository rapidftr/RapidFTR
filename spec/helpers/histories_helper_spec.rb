require 'spec_helper'

describe HistoriesHelper do
  before do
    @view = Object.new
    @view.extend(HistoriesHelper)
    @view.extend(ChildrenHelper)
  end

  it "should have change wording when 'from' and 'to' values exist" do
    @view.history_wording("London", "New York").should == "changed from London to New York"
  end

  it "should have initial wording when 'from' value is empty" do
    @view.history_wording("", "New York").should == "initially set to New York"
  end

  it "should have initial wording when 'from' value is nil" do
    @view.history_wording(nil, "New York").should == "initially set to New York"
  end

  describe "#flag_change_message" do

    it "should get the flag change message from the history" do
        history = {'changes' => {'flag_message' => {'to' => 'message'}}}
        @view.flag_change_message(history).should == 'message'
    end

    it "should return an empty string if no changes have been made" do
      history = {'changes' => {}}
      @view.flag_change_message(history).should == ''
    end
  end
end
