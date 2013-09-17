require 'spec_helper'

describe Enquiry do

  describe 'validation' do
    it 'should not create enquiry without criteria' do
      enquiry = create_enquiry_with_created_by('user name', {:reporter_name => 'Vivek'})
      enquiry.should_not be_valid
      enquiry.errors[:criteria].should == ["Please add criteria to your enquiry"]
    end

    it "should not create enquiry with empty criteria" do
      enquiry = create_enquiry_with_created_by('user name', {:reporter_name => 'Vivek', :criteria => {}})
      enquiry.should_not be_valid
      enquiry.errors[:criteria].should == ["Please add criteria to your enquiry"]
    end

    it "should not create enquiry without reporter_name" do
      enquiry = create_enquiry_with_created_by('user name', {:criteria => {:name=>'Child name'}})
      enquiry.should_not be_valid
      enquiry.errors[:reporter_name].should == ["Please add reporter name to your enquiry"]
    end

    it "should not create enquiry with empty reporter name" do
      enquiry = create_enquiry_with_created_by('user name', {:criteria => {:name=>''}})
      enquiry.should_not be_valid
      enquiry.errors[:reporter_name].should == ["Please add reporter name to your enquiry"]
    end

    it "should not create enquiry without reporter details" do
      enquiry = create_enquiry_with_created_by('user name', {:reporter_name => 'Vivek',:criteria => {:name=>'Child name'}})
      enquiry.should_not be_valid
      enquiry.errors[:reporter_details].should == ["Please add reporter details to your enquiry"]
    end

    it "should not create enquiry without empty reporter details" do
      enquiry = create_enquiry_with_created_by('user name', {:reporter_name => 'Vivek', :reporter_details => {},:criteria => {:name=>'Child name'}})
      enquiry.should_not be_valid
      enquiry.errors[:reporter_details].should == ["Please add reporter details to your enquiry"]
    end

  end

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

  describe "all_enquires" do
    xit "should return a list of all enquiries" do
      save_valid_enquiry('user1', 'enquiry_id' => 'id1')
      save_valid_enquiry('user2', 'enquiry_id' => 'id2')
      Enquiry.all.size.should == 2
    end
  end

  private

  def create_enquiry_with_created_by(created_by,options = {}, organisation = "UNICEF")
    user = User.new({:user_name => created_by, :organisation=> organisation})
    Enquiry.new_with_user_name( user, options)
  end

  def save_valid_enquiry(user, options = {}, organisation = "UNICEF")
    enquiry = create_enquiry_with_created_by(user, options, organisation)
    enquiry.should be_valid
    enquiry.save!
  end

end