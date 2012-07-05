require 'spec_helper'

describe 'users/_edittable_user.html.erb' do
  describe "User permission level" do
    it "should not be allowed to be updated by user" do
      user = User.new()
      user.disabled = false
      user.user_name = "someusername"
      @controller.template.stub!(:is_admin?).and_return(false)
      
      render :locals => { :current_user_name => "someusername", :edittable_user => user }

      response.body.should_not =~ /<input.*user\[permission\].*type="radio"/
    end
  end
end
