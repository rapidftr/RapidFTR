require 'spec_helper'
describe 'users/_edittable_user.html.erb' do
  permission_regex = /<input .*user\[permission\].*>/
  describe "User permission level" do
    before :each do
      @user = User.new()
      @user.disabled = false
    end 
    it "should not be updateable" do
      @controller.template.stub!(:is_admin?).and_return(false)

      render :locals => { :edittable_user => @user }

      permission_regex.match(response.body).to_a.each do |p|
        p.should include("disabled")	
      end
    end
    it "should be allowed to be updated by admin" do
      @controller.template.stub!(:is_admin?).and_return(true)

      render :locals => { :edittable_user => @user }

      permission_regex.match(response.body).to_a.each do |p|
        p.should_not include("disabled")	
      end
    end
  end
end
