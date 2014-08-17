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

      allow(@controller).to receive(:session_expiry_timeout).and_return(5.minutes)
      @controller.session[:rftr_session_id] = @session.id
      @controller.session[:last_access_time] = 1.minute.ago.rfc2822
    end

    it "should fetch session expiry timeout from configuration" do
      allow(Rails.application.config.session_options[:rapidftr]).to receive(:[]).with(:web_expire_after).and_return(100.minutes)
      allow(@controller).to receive(:session_expiry_timeout).and_call_original
      expect(@controller.session_expiry_timeout).to eq(100.minutes)
    end

    it "should check successful authentication" do
      expect(@controller.send(:check_authentication)).to be_truthy
    end

    it "should raise ErrorResponse if no session ID" do
      expect do
        @controller.session[:rftr_session_id] = nil
        @controller.send :check_authentication
      end.to raise_error(ErrorResponse, I18n.t("session.has_expired"))
    end

    it "should raise ErrorResponse if no Access Timestamp" do
      expect do
        @controller.session[:last_access_time] = nil
        @controller.send :check_authentication
      end.to raise_error(ErrorResponse, I18n.t("session.has_expired"))
    end

    it "should raise ErrorResponse if access time expired" do
      expect do
        @controller.session[:last_access_time] = 6.minutes.ago.rfc2822
        @controller.send :check_authentication
      end.to raise_error(ErrorResponse, I18n.t("session.has_expired"))
    end

    xit "should raise ErrorResponse if device blacklisted" do
      expect do
        mock_session = Session.new
        mock_session.stub :device_blacklisted? => true
        @controller.stub :current_session => mock_session
        @controller.send :check_authentication
      end.to raise_error(ErrorResponse)
    end

  end
end
