require "spec_helper"

describe LogEntry do

  describe "CPIMS export logs" do

    it "should save with creation timestamp" do
      RapidFTR::Clock.stub!(:current_formatted_time).and_return("this is now")

      log_entry = LogEntry.create! :type => LogEntry::TYPE[:cpims], :username => "rapidftr", :organisation => "urc", :format => "cpims", :number_or_records => "123"

      log_entry[:created_at].should == "this is now"
    end
  end

end