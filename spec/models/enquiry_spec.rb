require 'spec_helper'

describe Enquiry do

  describe '#update_from_properties' do
    it "should update the enquiry" do
      enquiry = create_enquiry_with_created_by("jdoe", {:reporter_name => 'Vivek', :place => 'Kampala'})
      properties = {:reporter_name => 'DJ', :place => 'Kampala'}

      enquiry.update_from(properties)

      enquiry.reporter_name.should == 'DJ'
      enquiry['place'].should == 'Kampala'
    end
  end

  describe "new_with_user_name" do
    it "should create a created_by field with the user name and organisation" do
      enquiry = create_enquiry_with_created_by('jdoe', {'some_field' => 'some_value'}, "Jdoe-organisation")
      enquiry['created_by'].should == 'jdoe'
      enquiry['created_organisation'].should == 'Jdoe-organisation'

    end
  end

  describe "timestamp" do
    it "should create a posted_at and created_at fields with the current date" do
      Clock.stub!(:now).and_return(Time.utc(2010, "jan", 22, 14, 05, 0))
      enquiry = create_enquiry_with_created_by('some_user', 'some_field' => 'some_value')
      enquiry['posted_at'].should == "2010-01-22 14:05:00UTC"
      enquiry['created_at'].should == "2010-01-22 14:05:00UTC"
    end

    it "should use the supplied created at value" do
      enquiry = create_enquiry_with_created_by('some_user', 'some_field' => 'some_value', 'created_at' => '2010-01-14 14:05:00UTC')
      enquiry['created_at'].should == "2010-01-14 14:05:00UTC"
    end
  end

  private

  def create_enquiry_with_created_by(created_by,options = {}, organisation = "UNICEF")
    user = User.new({:user_name => created_by, :organisation=> organisation})
    Enquiry.new_with_user_name( user, options)
  end

end