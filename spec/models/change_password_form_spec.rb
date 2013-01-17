require 'spec_helper'

describe Forms::ChangePasswordForm do

  describe "Validation" do

    it "should not be valid when user does not exits" do
      password_form = build :change_password_form, :user => nil
      password_form.valid?
      password_form.errors[:user].should_not be_empty
    end

    it "should not be valid when old password is empty" do
      change_password_form = build :change_password_form, :old_password => ' '
      change_password_form.valid?
      change_password_form.errors[:old_password].should_not be_empty
    end

    it "should be valid when old password is not empty" do
      password_form = build :change_password_form, :old_password => 'password'
      password_form.valid?
      password_form.errors[:old_password].should be_empty
    end

    it "should not be valid when new password is empty" do
      password_form = build :change_password_form, :new_password => ' '
      password_form.valid?
      password_form.errors[:new_password].should_not be_empty
    end

    it "should be valid when new password is not empty" do
      password_form = build :change_password_form, :new_password => 'password'
      password_form.valid?
      password_form.errors[:new_password].should be_empty
    end

  end
end