require 'spec_helper'

describe WeeklyReport do
  describe '#data' do
    before :each do
      basic_identity_fields = [
        Field.new("name" => "protection_status", "display_name" => "Protection Status", "type" => "select_box", "option_strings_text" => "Unaccompanied\nSeparated"),
        Field.new("name" => "ftr_status", "display_name" => "FTR Status", "type" => "select_box", "option_strings_text" => "Identified\nVerified\nTracing On-Going\nFamily Located-Cross-Border FR Pending\nFamily Located- Inter-Camp FR Pending\nReunited\nExported to CPIMS\nRecord Invalid"),
        Field.new("name" => "gender", "display_name" => "Sex", "type" => "select_box", "option_strings_text" => "Male\nFemale"),
      ]
      create :form_section, "name" =>"Basic Identity", "visible"=>true, :order=> 1, :unique_id=>"basic_identity", "editable"=>true, :fields => basic_identity_fields, :perm_enabled => true

      @user = User.new(:user_name => "faris")
      @child1 = Child.new_with_user_name(@user, {:name => "childOne", :protection_status => "Unaccompanied", :gender => "Male", :ftr_status => "Identified"}).save!
      @child2 = Child.new_with_user_name(@user, {:name => "childTwo", :protection_status => "Separated", :gender => "Male", :ftr_status => "Tracing On-Going"}).save!
      @child3 = Child.new_with_user_name(@user, {:name => "childThree", :protection_status => "Separated", :gender => "Female", :ftr_status => "Family Located- Inter-Camp FR Pending"}).save!
    end

    after :all do
      FormSection.all.each { |form| form.destroy }
      Child.all.each { |c| c.destroy }
      User.all.each { |user| user.destroy }
    end

    it "should provide data for weekly report" do
      data = WeeklyReport.data
      report = CSV.parse data

      expect(report[0]).to eq(["protection status", "gender", "ftr status", "total"])
      expect(report.size).to eq(33)
      number_of_rows_with_one_child = report.select { |row| row[3] == "1" }.size
      number_of_blank_rows = report.select { |row| row[3] == "0" }.size
      expect(number_of_rows_with_one_child).to be 3
      expect(number_of_blank_rows).to be 29
      expect(report).to include ["Unaccompanied", "Male", "Identified", "1"]
      expect(report).to include ["Separated", "Male", "Tracing On-Going", "1"]
      expect(report).to include ["Separated", "Male", "Reunited", "0"]
    end
  end

  it "should create document with weekly report data" do
    report = stub_model(Report)
    WeeklyReport.stub :data => 'stub data'
    allow(Report).to receive(:new).with(:as_of_date => Date.today, :report_type => 'weekly_report').and_return(report)
    expect(report).to receive(:create_attachment).with(:name => Date.today.strftime("weekly-report-%Y-%m-%d.csv"), :file => 'stub data', :content_type => 'text/csv').and_return(nil)
    expect(report).to receive(:save!).and_return(nil)

    expect(WeeklyReport.generate!).to eq(report)
  end

  it "should schedule every monday" do
    scheduler = double()
    expect(scheduler).to receive(:cron).with("1 0 * * MON").and_return(true)

    WeeklyReport.schedule scheduler
  end
end
