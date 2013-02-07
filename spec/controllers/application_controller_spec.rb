require 'spec_helper'

describe ApplicationController do

  let(:user_full_name) { 'Bill Clinton' }
  let(:user) { User.new(:full_name => user_full_name) }
  let(:session) { mock('session', :user => user) }

  describe 'current_user_full_name' do
    it 'should return the user full name from the session' do
      controller.stub!(:current_session).and_return(session)
      subject.current_user_full_name.should == user_full_name
    end
  end

  describe 'locale' do
    after :each do
      I18n.locale = I18n.default_locale
    end

    it "should be set to default" do
      controller.stub!(:current_session).and_return(session)
      @controller.set_locale
      I18n.locale.should == I18n.default_locale
    end
  end

  describe "user" do
    it "should return me the current logged in user" do
      user = User.new(:user_name => 'user_name', :role_names => ["default"])
      User.should_receive(:find_by_user_name).with('user_name').and_return(user)
      session = Session.new :user_name => user.user_name
      controller.stub(:get_session).and_return(session)
      controller.current_user.user_name.should == 'user_name'
    end
  end

end
