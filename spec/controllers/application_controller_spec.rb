require 'spec_helper'

describe ApplicationController do

  describe 'current_user_full_name' do

    let(:user_full_name) { 'Bill Clinton' }
    let(:user) { User.new(:full_name => user_full_name) }
    let(:session) { Session.for_user(user, nil) }

    it 'should return the user full name from the session' do
      User.stub!(:find_by_user_name).and_return(user)
      Session.stub('get_from_cookies').and_return(session)
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

end
