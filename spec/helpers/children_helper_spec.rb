require 'spec_helper'

describe ChildrenHelper do

  context "View module" do
    it "should have PER_PAGE constant" do
      ChildrenHelper::View::PER_PAGE.should == 20
    end

    it "should have MAX_PER_PAGE constant" do
      ChildrenHelper::View::MAX_PER_PAGE.should == 9999
    end
  end

  context "EditView module" do
    it "should have ONETIME_PHOTOS_UPLOAD_LIMIT constant" do
      ChildrenHelper::EditView::ONETIME_PHOTOS_UPLOAD_LIMIT.should == 5
    end
  end

  describe '#thumbnail_tag' do
    it 'should use current photo key if photo ID is not specified' do
      child = stub_model Child, :id => 1001, :current_photo_key => 'current'
      helper.thumbnail_tag(child).should == '<img src="/children/1001/thumbnail/current" />'
    end
    it 'should use photo ID if specified' do
      child = stub_model Child, :id => 1001, :current_photo_key => 'current'
      helper.thumbnail_tag(child, 'custom-id').should == '<img src="/children/1001/thumbnail/custom-id" />'
    end
  end

  #Delete this example and add some real ones or delete this file
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ChildrenHelper)
  end

  describe "#link_to_update_info" do
    it "should not show link if child has not been updated" do
      child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
      child.stub!(:has_one_interviewer?).and_return(true)
      helper.link_to_update_info(child).should be_nil
    end

    it "should show link if child has been updated by multiple people" do
      child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
      child.stub :has_one_interviewer? => false, :persisted? => true
      helper.link_to_update_info(child).should =~ /^<a href=.+>and others<\/a>$/
    end
  end
  describe "field_for_display" do
    it "should return the string value where set" do
      helper.field_value_for_display("Foo").should == "Foo"
    end
    it "should return empty string if field is nil or 0 length" do
      helper.field_value_for_display("").should == ""
      helper.field_value_for_display(nil).should == ""
      helper.field_value_for_display([]).should == ""
    end
    it "should comma separate values if field value is an array" do
      helper.field_value_for_display(["A", "B", "C"]).should == "A, B, C"
    end
  end

  describe "#text_to_identify_child" do
    it "should show the child short id if name is not present" do
      identifier = "00001234567"
      child = Child.new(:unique_identifier => identifier)
      helper.text_to_identify_child(child).should == "1234567"
    end

    it "should show the name if it is present" do
      name = "Ygor"
      child = Child.new(:name => name,:unique_identifier => '123412341234')
      helper.text_to_identify_child(child).should == 'Ygor: 2341234'
    end

    it "should show the child unique id if name is empty" do
      unique_identifier = "AnID"
      child = Child.new(:name => "", :unique_identifier => unique_identifier)
      helper.text_to_identify_child(child).should == unique_identifier
    end
  end

  describe "#flag_summary_for_child" do
    it "should show the flag summary for the child" do
      @current_user = stub_model(User)
      @current_user.stub!(:localize_date).and_return "19 September 2012 at 18:39 (UTC)"

      child = Child.new(:name => "Flagged Child",
                        :flag_message => "Fake entity",
                        :histories => [{"datetime"=>"2012-09-19 18:39:05UTC", "changes"=>{"flag"=>{"to"=>"true"}}, "user_name"=>"Admin user 1"}])

      helper.stub!(:current_user => @current_user)
      helper.strip_tags(helper.flag_summary_for_child(child)).should == "Flagged By Admin user 1 on 19 September 2012 at 18:39 (UTC) Because Fake entity"
    end
  end
end
