require 'spec_helper'
describe 'users/_editable_user.html.erb' do
  describe "User permission level" do
    before :each do
      @user = User.new()
      @user.disabled = false
      @user.user_name = "test user"
      @user.permissions = [ ]
      view.stub!(:is_admin?)
    end
    it "should not be updateable" do
      view.stub!(:editing_ourself?).and_return(true)

      render :partial => 'users/editable_user.html.erb', :locals => { :editable_user => @user }

      permissions {|p| p.should include("disabled") }
    end
    it "should be allowed to be updated when editing other person" do
      view.stub!(:editing_ourself?).and_return(false)

      render :partial => 'users/editable_user.html.erb', :locals => { :editable_user => @user }

      permissions {|p| p.should_not include("disabled") }
    end
    def permissions(&block)
      permission_regex = /<input .*user\[permission\].*>/
      permission_regex.match(rendered).to_a.each do |p|
        block.call(p)
      end
    end
  end
end
