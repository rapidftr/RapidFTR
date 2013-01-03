require 'spec_helper'

describe AdminController do
  before :each do
    fake_admin_login
  end

  after :each do
    I18n.default_locale = :en
  end

  it "should set the given locale as default" do
    put :update, :locale => "fr"
    I18n.default_locale.should == :fr
  end
end

