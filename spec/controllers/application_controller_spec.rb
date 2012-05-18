require 'spec_helper'

describe ApplicationController do

  describe 'current_user_full_name' do

    let(:user_full_name) { 'Bill Clinton' }
    let(:user) { User.new(:full_name => user_full_name) }
    let(:session) { Session.for_user(user, nil) }

    it 'should return the user full name from the session' do
      Session.stub('get_from_cookies').and_return(session)
      subject.current_user_full_name.should == user_full_name
    end
  end

end