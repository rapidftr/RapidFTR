require 'spec_helper'

describe ChildHistoriesHelper, :type => :helper do
  before do
    @view = Object.new
    @view.extend(ChildHistoriesHelper)
    @view.extend(ChildrenHelper)
  end

  it "should have change wording when 'from' and 'to' values exist" do
    expect(@view.history_wording('London', 'New York')).to eq('changed from London to New York')
  end

  it "should have initial wording when 'from' value is empty" do
    expect(@view.history_wording('', 'New York')).to eq('initially set to New York')
  end

  it "should have initial wording when 'from' value is nil" do
    expect(@view.history_wording(nil, 'New York')).to eq('initially set to New York')
  end

  describe '#new_value_for' do

    it 'should get the flag change message from the history' do
      history = {'changes' => {'flag_message' => {'to' => 'message'}}}
      expect(@view.new_value_for(history, 'flag_message')).to eq('message')
    end

    it 'should return an empty string if no changes have been made' do
      history = {'changes' => {}}
      expect(@view.new_value_for(history, 'flag_message')).to eq('')
    end
  end
end
