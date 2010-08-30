require 'spec_helper'

describe ChecksAuthentication, :type => :normal do

  class FakeController
    include LoadsSession

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

  def set_header(key,value)
    @controller.request.headers[key] = value
  end
  
  def set_session_token_cookie(value = 'token_in_cookie')
    @controller.cookies[Session::COOKIE_KEY] = value
  end

  it "should use a token supplied in cookies" do
    set_session_token_cookie 'token_in_cookie'
    Session.should_receive(:get).with('token_in_cookie').and_return(:fake_session)
    @controller.send(:get_session).should == :fake_session
  end

  it "should use a token supplied in the header" do
    set_header 'Authorization','RFTR_Token token_in_header'
    Session.should_receive(:get).with('token_in_header').and_return(:fake_session)
    @controller.send(:get_session).should == :fake_session
  end

  it "should prefer authorization token in header over cookie" do
    set_session_token_cookie 'token_in_cookie'
    set_header 'Authorization','RFTR_Token token_in_header'
    Session.should_receive(:get).with('token_in_header').and_return(:fake_session)
    @controller.send(:get_session).should == :fake_session
  end

  it "should ignore Authorization header that doesn't use our custom scheme" do
    set_header 'Authorization','Basic token_in_header'
    Session.should_not_receive(:get)
    @controller.send(:get_session).should == nil
  end

  it "should return nil if no token provided in header or cookie" do
    Session.should_not_receive(:get)
    @controller.send(:get_session).should == nil
  end

end
