require 'spec_helper'

describe "user_histories/index.html.erb" do
  describe "user history" do

    before do
      @user = mock(:user_name => "Bob")
    end

    describe "newly created user" do
      it "should render user has no activities" do
        assign(:histories, {})
        assign(:user,  @user)

        render :template => "user_histories/index.html.erb"

        rendered.should have_tag(".history-details") do
          with_tag("li", /Bob has no activity./)
        end
      end
    end
  end
end