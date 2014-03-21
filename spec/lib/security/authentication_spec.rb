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
    end

    it "should get token from session cookie" do
      mock_session = Session.new
      @controller.session[:rftr_session_id] = "test_session_id"
      Session.should_receive(:get).with('test_session_id').and_return(mock_session)
      @controller.send(:current_session).should == mock_session
    end

    it "should raise AuthenticationFailure if no session ID" do
      lambda {
        @controller.session[:rftr_session_id] = nil
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure)
    end

    it "should raise AuthenticationFailure if no such session object" do
      lambda {
        @controller.stub :current_session => nil
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure)
    end

    xit "should raise AuthenticationFailure if device blacklisted" do
      lambda {
        mock_session = Session.new
        mock_session.stub :device_blacklisted? => true
        @controller.stub :current_session => mock_session
        @controller.send :check_authentication
      }.should raise_error(AuthenticationFailure)
    end

  end
end
