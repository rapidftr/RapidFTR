require 'spec_helper'

describe ApplicationController do

  let(:user_full_name) { 'Bill Clinton' }
  let(:user) { User.new(:full_name => user_full_name) }
  let(:session) { mock('session', :user => user) }

  describe 'current_user_full_name' do
    it 'should return the user full name from the session' do
      controller.stub!(:current_session).and_return(session)
      subject.current_user_full_name.should == user_full_name
    end
  end

  describe 'locale' do
    before :each do
      I18n.locale = I18n.default_locale = :en
    end
    after :each do
      I18n.locale = I18n.default_locale
    end

    it "should be set to default" do
      controller.stub!(:current_session).and_return(session)
      @controller.set_locale
      I18n.locale.should == I18n.default_locale
    end

    it "should be change the locale" do
      user = mock('user', :locale => :ar)
      session = mock('session', :user => user)
      controller.stub!(:current_session).and_return(session)

      @controller.set_locale
      user.locale.should == I18n.locale
    end

    context "when hasn't translations to locale" do
      before :each do
        user = mock('user', :locale => :ar)
        session = mock('session', :user => user)
        controller.stub!(:current_session).and_return(session)
      end

      xit "should set be set to default" do

      end
    end
  end

  describe "user" do
    it "should return me the current logged in user" do
      user = User.new(:user_name => 'user_name', :role_names => ["default"])
      User.should_receive(:find_by_user_name).with('user_name').and_return(user)
      session = Session.new :user_name => user.user_name
      controller.stub(:get_session).and_return(session)
      controller.current_user.user_name.should == 'user_name'
    end
  end

  describe "update activity" do
    it "should not update session if the session expiry is not less 19 minutes from now" do
      expires_at = Time.now + 20.minutes
      session = Session.new(:user_name => user.user_name, :expires_at => expires_at)
      controller.stub(:get_session).and_return(session)
      session.should_not_receive(:save)
      controller.send(:update_activity_time)
    end

    it "should update session if the session expiry is less 19 minutes from now" do
      expires_at = Time.now + 18.minutes
      session = Session.new(:user_name => user.user_name, :expires_at => expires_at)
      controller.stub(:get_session).and_return(session)
      session.should_receive(:save)
      controller.send(:update_activity_time)
    end
  end

  describe '#send_encrypted_file' do
    it 'should send encrypted zip with password' do
      filename = "test_file.pdf"
      content  = "TEST CONTENT"
      password = "test_password"

      controller.should_receive(:send_file) do |file, opts|
        Zip::Archive.open(file) do |ar|
          ar.decrypt password
          ar.fopen(filename) do |f|
            f.read.should == content
          end
        end
      end

      UUIDTools::UUID.stub! :random_create => "encrypt_spec"
      controller.params[:password] = password
      controller.send(:send_encrypted_file, content, :filename => filename)
    end

    it 'should save data to tmp folder' do
      CleanupEncryptedFiles.stub! :dir_name => 'test_dir_name'
      FileUtils.should_receive(:mkdir_p).with('test_dir_name').and_return(true)
      filename = controller.send :generate_encrypted_filename
      filename.should start_with 'test_dir_name'
    end
  end

end
