require 'spec_helper'

describe "users/_user_disabled_checkbox.html.erb" do
  describe "Viewing users disabled status as a checkbox" do

    describe "when current user is the same" do
      it "should not show checkbox" do
        user = User.new()
        user.disabled = false
        user.user_name = "someusername"

        render :partial => 'users/user_disabled_checkbox.html.erb', :locals => {:current_user_name => "someusername", :user => user}

        rendered.should_not =~ /checkbox/
      end
    end

    describe "when current user is not the same" do
      before :each do
        @user = User.new()
        @user.user_name = "someusername"
      end

      it "should show checkbox as NOT checked for enabled user" do
        @user.disabled = "false"

        render :partial => 'users/user_disabled_checkbox.html.erb', :locals => {
          :current_user_name => "different",
          :user => @user
        }

        rendered.should =~ /checkbox/
        rendered.should_not =~ /checked/
      end

      it "should show checkbox as checked for disabled user" do
        @user.disabled = "true"

        render :partial => 'users/user_disabled_checkbox.html.erb', :locals => {
          :current_user_name => "different",
          :user => @user
        }

        rendered.should =~ /checkbox/
        rendered.should =~ /checked/
      end
    end

  end
end
