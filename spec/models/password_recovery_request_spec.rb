require 'spec_helper'

describe Login do
  describe "validation" do
    it "" do
      password_recovery_request = PasswordRecoveryRequest.new :user_name => ""
      password_recovery_request.should_not be_valid
    end
  end
end
