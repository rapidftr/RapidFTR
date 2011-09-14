require 'spec_helper'

class FakeRecordWithHistory
  attr_reader :id

  def initialize user = "Bob", created = "2010/12/31 22:06:00 +0000"
    @id = "ChildId"
   @fields = {
     "histories"=> [],
     "created_at" => created,
     "created_by" => user
   }
  end

  def add_history history
    @fields["histories"].unshift(history)
  end

  def add_photo_change username, date, *new_photos
    self.add_history({
             "changes" => {
                 "photo_keys" => {
                     "added" => new_photos
                 }
             },
             "user_name" => username,
             "datetime" => date
          })
  end

  def add_single_change username, date, field, from, to
    self.add_history({
             "changes" => {
                 field => {
                     "from" => from,
                     "to" => to
                 }
             },
             "user_name" => username,
             "datetime" => date
          })
  end

  def [](field)
     @fields[field]
   end
end

describe "histories/show.html.erb" do

  describe "child history" do
    before do
      FormSection.stub!(:all_child_field_names).and_return(["age", "last_known_location", "current_photo_key"])
        @user = mock(:user)
        @user.stub!(:time_zone).and_return TZInfo::Timezone.get("UTC")
    end

    describe "rendering history for a newly created record" do
      it "should render only the creation record" do
        child = FakeRecordWithHistory.new "Bob", "2010/12/31 20:55:00 +0000"
        assigns[:child] = child
        assigns[:user] = @user
        render
        response.should have_selector(".history-details li", :count => 1)
      	response.should have_tag(".history-details") do
          with_tag("li", /2010-12-31 20:55:00 UTC Record created by Bob/)
      	end
      end
    end

    describe "rendering the history of a flagged child record" do
      before do
        #Set up a child record and then flag it as suspect
        @user = mock(:user)
        @user.stub!(:time_zone).and_return TZInfo::Timezone.get("US/Samoa")
      end

      it "should display the time of the change using the users timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "flag", "false", "true"
        assigns[:child] = child
        assigns[:user] = @user

        render

      	response.should have_tag(".history-details") do
          with_tag("li", "2010-12-31 09:55:00 -1100 Record was flagged by rapidftr because:")
        end
      end
    end

    describe "rendering changes to photos" do
      before do
        @user = mock(:user)
        @user.stub!(:time_zone).and_return TZInfo::Timezone.get("UTC")
      end

      it "should render photo change record with links when adding a photo to an existing record" do
        child = FakeRecordWithHistory.new "Bob", "Yesterday"
        child.add_photo_change "rapidftr", "2010/12/31 20:55:00 +0000", "new_photo_key"

        assigns[:child] = child
        assigns[:user] = @user
        render

      	response.should have_tag(".history-details") do
          with_tag("li", /Photo\s+added/)
      	end
      end

      it "should render photo change record with links when adding photos to an existing record" do
        child = FakeRecordWithHistory.new "Bob", "Yesterday"
        child.add_photo_change "rapidftr", "2010/12/31 20:55:00 +0000", "new_photo_key", "new_photo_key2"

        assigns[:child] = child
        assigns[:user] = @user
        render

      	response.should have_tag(".history-details") do
          with_tag("li", /Photos\s+added/)
      	end
      end
    end

    describe "rendering changes to audio" do
      before do
        @user = mock(:user)
        @user.stub!(:time_zone).and_return TZInfo::Timezone.get("UTC")
      end

      it "should render audio change record" do
        child = FakeRecordWithHistory.new 
        child.add_single_change "rapidftr", "2010/12/31 20:55:00 +0000", "recorded_audio", "First", "Second"

        assigns[:child] = child
        assigns[:user] = @user
        render

      	response.should have_tag(".history-details") do
      		with_tag("li", /2010-12-31 20:55:00 UTC Audio changed from First to Second by rapidftr/)
      	end
      end

      it "should render audio change record with links when adding a sound file to an existing record for first time" do
        child = FakeRecordWithHistory.new
        child.add_single_change "rapidftr", "2010/12/31 20:55:00 +0000", "recorded_audio", nil, "Audio"

        assigns[:child] = child
        assigns[:user] = @user
        render

      	response.should have_tag(".history-details") do
          with_tag("li", /2010-12-31 20:55:00 UTC Audio Audio added by rapidftr/)
      	end
      end
    end

    describe "rendering several history entries" do
      before do
        @user = mock(:user)
        @user.stub!(:time_zone).and_return TZInfo::Timezone.get("UTC")
      end

      it "should order history log from most recent change to oldest change" do
        child = FakeRecordWithHistory.new
        child.add_single_change "rapidftr", "2010/02/20 12:04:00 +0000", "age", "6", "7"
        child.add_single_change "rapidftr", "2010/02/20 13:04:00 +0000", "last_known_location", "Haiti", "Santiago"
        child.add_single_change "rapidftr", "2011/02/20 12:04:00 +0000", "age", "7", "8"

        assigns[:child] = child
        assigns[:user] = @user
        render

        response.should have_tag(".history-details") do
          with_tag("li", /Age changed from 7 to 8/)
          with_tag("li", /Last known location changed from Haiti to Santiago/)
          with_tag("li", /Age changed from 6 to 7/)
          with_tag("li", /Record created by/)
        end
      end
    end
  end
end
