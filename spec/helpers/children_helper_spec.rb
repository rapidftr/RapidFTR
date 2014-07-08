require 'spec_helper'

describe ChildrenHelper, :type => :helper do

  context "View module" do
    it "should have PER_PAGE constant" do
      expect(ChildrenHelper::View::PER_PAGE).to eq(20)
    end

    it "should have MAX_PER_PAGE constant" do
      expect(ChildrenHelper::View::MAX_PER_PAGE).to eq(9999)
    end
  end

  context "EditView module" do
    it "should have ONETIME_PHOTOS_UPLOAD_LIMIT constant" do
      expect(ChildrenHelper::EditView::ONETIME_PHOTOS_UPLOAD_LIMIT).to eq(5)
    end
  end

  describe '#thumbnail_tag' do
    it 'should use current photo key if photo ID is not specified' do
      child = stub_model Child, :id => 1001, :current_photo_key => 'current'
      expect(helper.thumbnail_tag(child)).to eq('<img src="/children/1001/thumbnail/current" />')
    end
    it 'should use photo ID if specified' do
      child = stub_model Child, :id => 1001, :current_photo_key => 'current'
      expect(helper.thumbnail_tag(child, 'custom-id')).to eq('<img src="/children/1001/thumbnail/custom-id" />')
    end
  end

  #Delete this example and add some real ones or delete this file
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    expect(included_modules).to include(ChildrenHelper)
  end

  describe "#link_to_update_info" do
    it "should not show link if child has not been updated" do
      child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
      allow(child).to receive(:has_one_interviewer?).and_return(true)
      expect(helper.link_to_update_info(child)).to be_nil
    end

    it "should show link if child has been updated by multiple people" do
      child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
      child.stub :has_one_interviewer? => false, :persisted? => true
      expect(helper.link_to_update_info(child)).to match(/^<a href=.+>and others<\/a>$/)
    end
  end
  describe "field_for_display" do
    it "should return the string value where set" do
      expect(helper.field_value_for_display("Foo")).to eq("Foo")
    end
    it "should return empty string if field is nil or 0 length" do
      expect(helper.field_value_for_display("")).to eq("")
      expect(helper.field_value_for_display(nil)).to eq("")
      expect(helper.field_value_for_display([])).to eq("")
    end
    it "should comma separate values if field value is an array" do
      expect(helper.field_value_for_display(["A", "B", "C"])).to eq("A, B, C")
    end
  end

  describe "#flag_summary_for_child" do
    it "should show the flag summary for the child" do
      @current_user = stub_model(User)
      allow(@current_user).to receive(:localize_date).and_return "19 September 2012 at 18:39 (UTC)"

      child = Child.new(:name => "Flagged Child",
                        :flag_message => "Fake entity",
                        :histories => [{"datetime"=>"2012-09-19 18:39:05UTC", "changes"=>{"flag"=>{"to"=>"true"}}, "user_name"=>"Admin user 1"}])

      helper.stub(:current_user => @current_user)
      expect(helper.strip_tags(helper.flag_summary_for_child(child))).to eq("Flagged By Admin user 1 on 19 September 2012 at 18:39 (UTC) Because Fake entity")
    end
  end
end
