require 'spec_helper'

describe ReportsGenerator do
	it "should generate csv report" do 
    setup_form_sections 
		user = User.new(:user_name => "faris")
		Child.new_with_user_name (user, {:name => "childOne", :protection_status => "Unaccompanied", :gender => "Male", :ftr_status => "Identified"}).save
		Child.new_with_user_name (user, {:name => "childTwo", :protection_status => "Separated", :gender => "Male", :ftr_status => "Tracing On-Going"}).save
		Child.new_with_user_name (user, {:name => "childThree", :protection_status => "Separated", :gender => "Female", :ftr_status => "Family Located- Inter-Camp FR Pending"}).save

		ReportsGenerator.generate

    expected_filename = "#{Date.today.year}-#{Date.today.month}-#{Date.today.day}.csv"
    report = FasterCSV.read("#{Rails.root}/reports/#{expected_filename}")

    report[0].should == ["protection status", "gender", "ftr status", "total"]
    report.size.should == 33
    number_of_rows_with_one_child = report.select{|row| row[3] == "1" }.size
    number_of_blank_rows = report.select{|row| row[3] == "0" }.size
    number_of_rows_with_one_child.should be 3
    number_of_blank_rows.should be 29
    report.should include ["Unaccompanied", "Male", "Identified", "1"]
    report.should include ["Separated", "Male", "Tracing On-Going", "1"]
    report.should include ["Separated", "Male", "Reunited", "0"]
  end

  def setup_form_sections
    basic_identity_fields = [
      Field.new("name" => "protection_status", "display_name" => "Protection Status", "type" => "select_box", "option_strings_text" => "Unaccompanied\nSeparated"),
      Field.new("name" => "ftr_status", "display_name" => "FTR Status", "type" => "select_box", "option_strings_text" => "Identified\nVerified\nTracing On-Going\nFamily Located-Cross-Border FR Pending\nFamily Located- Inter-Camp FR Pending\nReunited\nExported to CPIMS\nRecord Invalid"),
      Field.new("name" => "gender", "display_name" => "Sex", "type" => "select_box", "option_strings_text" => "Male\nFemale"),
    ]
    FormSection.create!("name" =>"Basic Identity", "visible"=>true, :order=> 1, :unique_id=>"basic_identity", "editable"=>true, :fields => basic_identity_fields, :perm_enabled => true)
  end

end