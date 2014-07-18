require "spec_helper"

describe LogEntry, :type => :model do

  it "should save with creation timestamp" do
    allow(RapidFTR::Clock).to receive(:current_formatted_time).and_return("this is now")

                # changed :format to :export_format because format is a reserved word
                # Searched through code and could not see anywhere other than in the specs where :format was being used
    log_entry = LogEntry.create! :type => LogEntry::TYPE[:cpims], :username => "rapidftr", :organisation => "urc", :export_format => "cpims", :number_or_records => "123"

    expect(log_entry[:created_at]).to eq("this is now")
  end

  it "should return all entries sorted by created_at date" do
    LogEntry.all.each(&:destroy)
    allow(Clock).to receive(:now).and_return(1.day.ago)
    old_entry = LogEntry.create! :type => LogEntry::TYPE[:csv], :username => "rapidftr", :organisation => "urc", :export_format => "cpims", :number_or_records => "123"
    allow(Clock).to receive(:now).and_return(1.day.from_now)
    newest_entry = LogEntry.create! :type => LogEntry::TYPE[:cpims], :username => "rapidftr", :organisation => "urc", :export_format => "cpims", :number_or_records => "123"
    allow(Clock).to receive(:now).and_return(2.days.ago)
    oldest_entry = LogEntry.create! :type => LogEntry::TYPE[:pdf], :username => "rapidftr", :organisation => "urc", :export_format => "cpims", :number_or_records => "123"

    entries = LogEntry.by_created_at(:descending => true).all
    expect(entries.size).to eq(3)
    expect(entries[0]['type']).to eq(LogEntry::TYPE[:cpims])
    expect(entries[1]['type']).to eq(LogEntry::TYPE[:csv])
    expect(entries[2]['type']).to eq(LogEntry::TYPE[:pdf])
  end
end
