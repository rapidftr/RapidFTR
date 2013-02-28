require 'spec_helper'

class FakeChildRecordWithHistory
  attr_reader :id

  def initialize user = "Bob", created = "2010/12/31 22:06:00 +0000"
    @id = "ChildId"
    @fields = {"histories"=> [], "created_at" => created}
  end

  def add_history history
    @fields["histories"].unshift(history)
  end

  def add_photo_change username, date, *new_photos
    self.add_history({"changes" => { "photo_keys" => {  "added" => new_photos}},
                         "user_name" => username,
                         "datetime" => date
                     })
  end

  def add_single_change username, date, field, from, to
    self.add_history({"changes" => {field => {"from" => from, "to" => to}},
                        "user_name" => username,
                        "datetime" => date
                     })
  end

  def [](field)
    @fields[field]
  end

  def last_updated_at
    Date.today
  end
end

describe "user_histories/index.html.erb" do
  describe "user history" do

    before do
      FormSection.stub!(:all_child_field_names).and_return(["age", "last_known_location", "current_photo_key"])
      @user = mock(:user_name => "Bob")
      @user.stub!(:time_zone).and_return TZInfo::Timezone.get("US/Samoa")
      @user.stub!(:localize_date).and_return "2010-12-31 09:55:00 SST"
    end

    describe "newly created user" do
      it "should render user has no activities" do
        child = FakeChildRecordWithHistory.new "Bob", "fake"
        assign(:child,  child)
        assign(:user,  @user)
        render

        rendered.should have_tag(".history-details") do
          with_tag("li", /Bob has no activity./)
        end
      end
    end

  end
end