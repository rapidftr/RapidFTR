require 'spec_helper'

describe ChecksAuthentication, :type => :normal do

  class FakeController
    include ChecksAuthentication

    attr_reader :cookies, :request

    def initialize
      @cookies = {}
      @request = OpenStruct.new(:headers => {})
    end
  end


  before :each do
    @controller = FakeController.new
    Session.stub!(:get)
  end

  def exercise_authentication_check
    @controller.send(:check_authentication)
  end

  def set_header(key,value)
    @controller.request.headers[key] = value
  end
  
  def set_session_token_cookie(value = 'token_in_cookie')
    @controller.cookies[Session::COOKIE_KEY] = value
  end

  def expect_auth_failure
    lambda{
      yield
    }.should( raise_error(AuthenticationFailure) )
  end

  it "should use a token supplied in cookies" do
    set_session_token_cookie 'token_in_cookie'
    Session.should_receive(:get).with('token_in_cookie').and_return(Session.new)
    exercise_authentication_check
  end

  it "should use a token supplied in the header" do
    set_header 'Authorization','RFTR_Token token_in_header'
    Session.should_receive(:get).with('token_in_header').and_return(Session.new)
    exercise_authentication_check
  end

  it "should ignore Authorization header that doesn't use our custom scheme" do
    set_header 'Authorization','Basic token_in_header'
    Session.should_not_receive(:get)
    expect_auth_failure do
      exercise_authentication_check
    end
  end

  it "should prefer the token in the header if there was a token in both header and cookies" do
    set_header 'Authorization','RFTR_Token token_in_header'
    set_session_token_cookie 'token_in_cookie'

    Session.should_receive(:get).with('token_in_header').and_return(Session.new)

    exercise_authentication_check
  end

  it "should raise the appropriate AuthenticationFailure if no token is supplied" do
    begin
      exercise_authentication_check
    rescue AuthenticationFailure => ex
      ex.token_provided?.should == false
      ex.message.should == 'no session token in headers or cookies'
    else
      fail( 'AuthenticationFailure not raised' )
    end
  end

  it "should raise the apropriate AuthenticationFailure if no session was found for the specified token" do
    set_session_token_cookie
    Session.stub!(:get).and_return(nil)

    begin
      exercise_authentication_check
    rescue AuthenticationFailure => ex
      ex.token_provided?.should == true
      ex.message.should == 'invalid session token'
    else
      fail( 'AuthenticationFailure not raised' )
    end
  end

  describe "Blacklisted" do

    it "should return 403 if a device is blacklisted" do
      set_session_token_cookie
      session = Session.new(:imei => "BLAH")
      session.stub!(:admin?).and_return(true)
      session.stub!(:device_blacklisted?).and_return(true)
      Session.stub!(:get).and_return(session)
      @controller.should_receive(:render).with(:status => 403, :json => session.imei)

      exercise_authentication_check
    end
  end
end
