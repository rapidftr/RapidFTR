require 'spec_helper'

describe Forms::ChangePasswordForm do

  describe "Validation" do
    it "should not be valid when old password is empty" do
      change_password_form = build :change_password_form, :old_password => ' '
      change_password_form.valid?
      change_password_form.errors[:old_password].should_not be_empty
    end
  end
end