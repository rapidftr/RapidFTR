require "spec_helper"

describe LogEntry do

  describe "CPIMS export logs" do

    it "should save" do
      LogEntry.create! :type => LogEntry::TYPE[:cpims_export], :username => "rapidftr", :organisation => "urc", :format => "cpims", :number_or_records => "123"
    end
  end

end