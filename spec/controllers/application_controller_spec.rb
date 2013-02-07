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
    before :each do
      @controller = ApplicationController.new
      @params, @cookies = {}, {}
      @controller.stub! :params => @params
      @controller.stub! :cookies => @cookies
    end

    after :each do
      I18n.locale = I18n.default_locale
    end

    it "should be set to default" do
      controller.stub!(:current_session).and_return(session)
      @controller.set_locale
      I18n.locale.should == I18n.default_locale
    end

    it "should be set from parameters" do
      @params[:locale] = :de
      @controller.set_locale
      I18n.locale.should == :de
    end

    it "should be set from parameters even if cookie is set" do
      @params[:locale] = :de
      @cookies[:locale] = :fr
      @controller.set_locale
      I18n.locale.should == :de
    end

    it "should be set from cookies" do
      @cookies[:locale] = :fr
      @controller.set_locale
      I18n.locale.should == :fr
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
