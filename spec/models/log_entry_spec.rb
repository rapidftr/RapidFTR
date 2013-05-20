require "spec_helper"

describe LogEntry do

	it "should save with creation timestamp" do
		RapidFTR::Clock.stub!(:current_formatted_time).and_return("this is now")

		log_entry = LogEntry.create! :type => LogEntry::TYPE[:cpims], :username => "rapidftr", :organisation => "urc", :format => "cpims", :number_or_records => "123"

		log_entry[:created_at].should == "this is now"
	end

	it "should return all entries sorted by created_at date" do
		LogEntry.all.each(&:destroy)
		Clock.stub!(:now).and_return(1.day.ago)
		old_entry = LogEntry.create! :type => LogEntry::TYPE[:csv], :username => "rapidftr", :organisation => "urc", :format => "cpims", :number_or_records => "123"
		Clock.stub!(:now).and_return(1.day.from_now)
		newest_entry = LogEntry.create! :type => LogEntry::TYPE[:cpims], :username => "rapidftr", :organisation => "urc", :format => "cpims", :number_or_records => "123"
		Clock.stub!(:now).and_return(2.days.ago)
		oldest_entry = LogEntry.create! :type => LogEntry::TYPE[:pdf], :username => "rapidftr", :organisation => "urc", :format => "cpims", :number_or_records => "123"

		entries = LogEntry.by_created_at(:descending => true)
		entries.size.should == 3
		entries[0][:type].should == LogEntry::TYPE[:cpims]
		entries[1][:type].should == LogEntry::TYPE[:csv]
		entries[2][:type].should == LogEntry::TYPE[:pdf]
	end
end