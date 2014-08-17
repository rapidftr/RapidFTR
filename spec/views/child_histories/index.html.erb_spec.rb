require 'spec_helper'
require 'helpers/fake_record_with_history'

describe "child_histories/index.html.erb", :type => :view do

  describe "child history" do
    before do
      allow(FormSection).to receive(:all_child_field_names).and_return(%w(age last_known_location current_photo_key))
      @user = double(:user)
    end

    describe "rendering history for a newly created record" do
      it "should render only the creation record" do
        allow(User).to receive(:find_by_user_name).with("me").and_return(user = double(:organisation => "stc", :localize_date => "2010-12-31 09:55:00 SST"))
        child = Child.create!(:name => "billybob", "created_by" => "me")
        assign(:child,  child)
        assign(:user,  user)
        render
        expect(rendered).to have_selector(".history-details li", :count => 1)
        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /Record created by Bob/)
        end
      end

      it "should display the date/time of creation using the user's timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        assign(:child,  child)
        assign(:user,  @user)

        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /2010-12-31 09:55:00 SST Record created/)
        end
      end

    end

    describe "rendering the history of a flagged child record" do
      before do
        # Set up a child record and then flag it as suspect
        @user = double(:user)
        allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("US/Samoa")
        allow(@user).to receive(:localize_date).and_return "2010-12-31 09:55:00 SST"
      end

      it "should display the date/time of the change using the user's timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "flag", "false", "true"
        assign(:child, child)
        assign(:user, @user)

        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", "2010-12-31 09:55:00 SST Record was flagged by rapidftr because:")
        end
      end

      it "should correctly format the change's' date/time" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "flag", "false", "true"
        assign(:child, child)
        assign(:user, @user)

        expect(@user).to receive(:localize_date).with("2010/12/31 20:55:00UTC", "%Y-%m-%d %H:%M:%S %Z")

        render
      end
    end

    describe "rendering changes to photos" do
      before do
        @user = double(:user)
        allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("UTC")
        allow(@user).to receive(:localize_date).and_return "2010-12-31 20:55:00 UTC"
      end

      it "should render photo change record with links when adding a photo to an existing record" do
        child = FakeRecordWithHistory.new "Bob", "Yesterday"
        child.add_photo_change "rapidftr", "2010/12/31 20:55:00 +0000", "new_photo_key"

        assign(:child, child)
        assign(:user, @user)
        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /Photo\s+added/)
        end
      end

      it "should render photo change record with links when adding photos to an existing record" do
        child = FakeRecordWithHistory.new "Bob", "Yesterday"
        child.add_photo_change "rapidftr", "2010/12/31 20:55:00 +0000", "new_photo_key", "new_photo_key2"

        assign(:child, child)
        assign(:user, @user)
        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /Photos\s+added/)
        end
      end

      it "should display the date/time of the change using the user's timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_photo_change "rapidftr", "2010/12/31 20:55:00 +0000", "new_photo_key"
        assign(:child, child)
        assign(:user, @user)

        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /2010-12-31 20:55:00 UTC\s+Photo\s+added by rapidftr/)
        end
      end

      it "should correctly format the change's date/time" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_photo_change "rapidftr", "2010/12/31 20:55:00 +0000", "new_photo_key"
        assign(:child, child)
        assign(:user, @user)

        expect(@user).to receive(:localize_date).with("2010/12/31 20:55:00 +0000", "%Y-%m-%d %H:%M:%S %Z")

        render
      end
    end

    describe "rendering changes to audio" do
      before do
        @user = double(:user)
        allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("UTC")
        allow(@user).to receive(:localize_date).and_return "2010-12-31 20:55:00 UTC"
      end

      it "should render audio change record" do
        child = FakeRecordWithHistory.new
        child.add_single_change "rapidftr", "2010/12/31 20:55:00 +0000", "recorded_audio", "First", "Second"

        assign(:child, child)
        assign(:user, @user)
        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /2010-12-31 20:55:00 UTC Audio changed from First to Second by rapidftr/)
        end
      end

      it "should render audio change record with links when adding a sound file to an existing record for first time" do
        child = FakeRecordWithHistory.new
        child.add_single_change "rapidftr", "2010/12/31 20:55:00 +0000", "recorded_audio", nil, "Audio"

        assign(:child, child)
        assign(:user, @user)
        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /.* UTC Audio Audio added by rapidftr/)
        end
      end

      it "should display the date/time of the change using the user's timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00 +0000", "recorded_audio", nil, "Audio"
        assign(:child, child)
        assign(:user, @user)

        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /2010-12-31 20:55:00 UTC Audio Audio added by rapidftr/)
        end
      end

      it "should correctly format the change's date/time" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00 +0000", "recorded_audio", nil, "Audio"
        assign(:child, child)
        assign(:user, @user)

        expect(@user).to receive(:localize_date).with("2010/12/31 20:55:00 +0000", "%Y-%m-%d %H:%M:%S %Z")

        render
      end
    end

    describe "rendering several history entries" do
      before do
        @user = double(:user)
        allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("UTC")
        allow(@user).to receive(:localize_date).and_return ""
      end

      it "should order history log from most recent change to oldest change" do
        child = FakeRecordWithHistory.new
        child.add_single_change "rapidftr", "2010/02/20 12:04:00 +0000", "age", "6", "7"
        child.add_single_change "rapidftr", "2010/02/20 13:04:00 +0000", "last_known_location", "Haiti", "Santiago"
        child.add_single_change "rapidftr", "2011/02/20 12:04:00 +0000", "age", "7", "8"

        assign(:child, child)
        assign(:user, @user)
        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /Age changed from 7 to 8/)
          with_tag("li", /Last known location changed from Haiti to Santiago/)
          with_tag("li", /Age changed from 6 to 7/)
          with_tag("li", /Record created by/)
        end
      end
    end

    describe "rendering changes to general attributes" do
      before do
        @user = double(:user)
        allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("US/Samoa")
        allow(@user).to receive(:localize_date).and_return "2010-12-31 09:55:00 SST"
      end

      it "should display the date/time of the change using the user's timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "nick_name", "", "Carrot"
        assign(:child, child)
        assign(:user, @user)

        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", "2010-12-31 09:55:00 SST Nick name initially set to Carrot by rapidftr")
        end
      end

      it "should correctly format the change's date/time" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "nick_name", "", "Carrot"
        assign(:child, child)
        assign(:user, @user)

        expect(@user).to receive(:localize_date).with("2010/12/31 20:55:00UTC", "%Y-%m-%d %H:%M:%S %Z")

        render
      end
    end

    describe "rendering the history of a reunited child record" do
      before do
        # Set up a child record and then flag it as suspect
        @user = double(:user)
        allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("US/Samoa")
        allow(@user).to receive(:localize_date).and_return "2010-12-31 09:55:00 SST"
      end

      it "should display the date/time of the change using the user's timezone setting" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "reunited", "", "true"
        assign(:child, child)
        assign(:user, @user)

        render

        expect(rendered).to have_tag(".history-details") do
          with_tag("li", /2010-12-31 09:55:00 SST Child status changed to reunited.*/)
        end
      end

      it "should correctly format the change's' date/time" do
        child = FakeRecordWithHistory.new "bob", "fake"
        child.add_single_change "rapidftr", "2010/12/31 20:55:00UTC", "reunited", "", "true"
        assign(:child, child)
        assign(:user, @user)

        expect(@user).to receive(:localize_date).with("2010/12/31 20:55:00UTC", "%Y-%m-%d %H:%M:%S %Z")

        render
      end
    end
  end
end
