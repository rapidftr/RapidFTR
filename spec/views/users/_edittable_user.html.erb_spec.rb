require 'spec_helper'

describe 'users/_edittable_user.html.erb' do
  describe "User permission level" do
  	before :each do
      @user = User.new()
      @user.disabled = false
  	end 
  	context "when user is not admin" do
  		before :each do 
  			@controller.template.stub!(:is_admin?).and_return(false)
  		end
  		it "should not be updateable" do
  			render :locals => { :edittable_user => @user }

  			response.body.should_not =~ /<input.*user\[permission\].*type="radio"/
  		end
  		it "should show Limited if user has limited access" do
  			@user.stub(:limited_access?).and_return(true)

				render :locals => { :edittable_user => @user }

  			response.body.should =~ /Limited/
  		end
  		it "should show Unlimited if user has unlimited access" do
  			@user.stub(:limited_access?).and_return(false)

				render :locals => { :edittable_user => @user }

  			response.body.should =~ /Unlimited/
  		end
   	end
  	it "should be allowed to be updated by admin" do
  		@controller.template.stub!(:is_admin?).and_return(true)

  		render :locals => { :edittable_user => @user }

  		response.body.should =~ /<input.*user\[permission\].*type="radio"/
  	end
  end
end