require 'spec_helper'

describe Forms::ChangePasswordForm, :type => :model do

  before :all do
    User.all.each {|u| u.destroy}
  end

  describe "Validation" do

    it "should be valid when user exits" do
      password_form = build :change_password_form
      password_form.valid?
      expect(password_form.errors[:user]).to be_empty
    end

    it "should not be valid when old password is empty" do
      change_password_form = build :change_password_form, :old_password => ' '
      change_password_form.valid?
      expect(change_password_form.errors[:old_password]).not_to be_empty
    end

    it "should be valid when old password is not empty" do
      password_form = build :change_password_form, :old_password => 'password'
      password_form.valid?
      expect(password_form.errors[:old_password]).to be_empty
    end

    it "should not be valid when new password is empty" do
      password_form = build :change_password_form, :new_password => ' '
      password_form.valid?
      expect(password_form.errors[:new_password]).not_to be_empty
    end

    it "should be valid when new password is not empty" do
      password_form = build :change_password_form, :new_password => 'password', :new_password_confirmation => 'password'
      password_form.valid?
      expect(password_form.errors[:new_password]).to be_empty
    end

    it "should not be valid when password confirmation is empty" do
      password_form = build :change_password_form, :new_password_confirmation => ' '
      password_form.valid?
      expect(password_form.errors[:new_password_confirmation]).not_to be_empty
    end

    it "should not be valid if confirmation does not match new password" do
      password_form = build :change_password_form, :new_password => 'password', :new_password_confirmation => 'wrong_confirm'
      expect(password_form).not_to be_valid
      expect(password_form.errors[:new_password_confirmation]).not_to be_empty
    end

    it "should not be valid if old password does not match existing one" do
      password_form = build :change_password_form, :old_password => "wrong_password"
      password_form.valid?
      expect(password_form.errors[:old_password]).to eq(["does not match current password"])
    end

    it "should be valid if old password match existing one" do
      password_form = build :change_password_form, :old_password => "password"
      password_form.valid?
      expect(password_form.errors[:old_password]).to be_empty
    end
  end

  describe "Reset" do
    it "should reset all fields" do
      password_form = build :change_password_form
      password_form.reset
      expect(password_form.old_password).to eq('')
      expect(password_form.new_password).to eq('')
      expect(password_form.new_password_confirmation).to eq('')
    end
  end

  describe "Execute" do
    it "should set user password to new password if all valid" do
      password_form = build :change_password_form, :old_password => "password",
                            :new_password => "new_password",
                            :new_password_confirmation => "new_password"
      password_before_execution = password_form.user.crypted_password
      password_form.execute
      password_after_execution = password_form.user.crypted_password

      expect(password_after_execution).not_to eq(password_before_execution)
    end

    it "should not set new password when not valid" do
      password_form = build :change_password_form, :old_password => "password",
                            :new_password => "new_password",
                            :new_password_confirmation => "wrong_new_password"
      password_before_execution = password_form.user.crypted_password
      password_form.execute
      password_after_execution = password_form.user.crypted_password
      expect(password_before_execution).to eq(password_after_execution)
    end

    it "should reset all fields when not valid" do
      password_form = build :change_password_form, :old_password => "password",
                            :new_password => "new_password",
                            :new_password_confirmation => "wrong_new_password"
      password_form.execute
      expect(password_form.old_password).to eq('')
      expect(password_form.new_password).to eq('')
      expect(password_form.new_password_confirmation).to eq('')
    end

    it "should return false when not valid" do
      password_form = build :change_password_form, :old_password => "password",
                            :new_password => "new_password",
                            :new_password_confirmation => "wrong_new_password"

      expect(password_form.execute).to be false
    end
  end
end