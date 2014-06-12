require 'spec_helper'

module Security
  describe Authentication, :type => :normal do

    class FakeController
      include Authentication

      attr_reader :session, :request

      def initialize
        @session = {}
        @request = OpenStruct.new(:headers => {})
      end
    end

    before :each do
      @controller = FakeController.new
      @session = create :session

      @controller.session[:rftr_session_id] = @session.id
      @controller.session[:last_access_time] = 1.minute.ago.rfc2822
    end

    it "should check successful authentication" do
      @controller.send(:check_authentication).should be_true
    end

    it "should raise AuthenticationFailure if no session ID" do
      lambda {
        @controller.session[:rftr_session_id] = nil
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure, I18n.t("session.has_expired"))
    end

    it "should raise AuthenticationFailure if no Access Timestamp" do
      lambda {
        @controller.session[:last_access_time] = nil
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure, I18n.t("session.has_expired"))
    end

    it "should raise AuthenticationFailure if access time expired" do
      lambda {
        @controller.session[:last_access_time] = 21.minutes.ago.rfc2822
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure, I18n.t("session.has_expired"))
    end

    xit "should raise AuthenticationFailure if device blacklisted" do
      lambda {
        mock_session = Session.new
        mock_session.stub! :device_blacklisted? => true
        @controller.stub! :current_session => mock_session
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure)
    end

  end
end
