require 'spec_helper'

describe ApplicationController do

  let(:user_full_name) { 'Bill Clinton' }
  let(:user) { User.new(:full_name => user_full_name) }
  let(:session) { mock('session', :user => user) }

  before :each do
    controller.session[:last_access_time] = Clock.now.rfc2822
  end

  describe 'current_user_full_name' do
    it 'should return the user full name from the session' do
      controller.stub!(:current_session).and_return(session)
      subject.current_user_full_name.should == user_full_name
    end
  end

  describe 'session expiry' do
    it 'should extend session lifetime' do
      access_time = DateTime.now
      Clock.stub(:now).and_return(access_time)
      controller.session[:last_access_time] = nil
      controller.extend_session_lifetime
      controller.session[:last_access_time].should == access_time.rfc2822
    end
  end

  describe 'locale' do
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
      controller.stub(:current_session).and_return(session)
      controller.current_user.user_name.should == 'user_name'
    end
  end

  describe '#encrypt_exported_files' do
    before :each do
      controller.params[:password] = 'test_password'
    end

    it 'should send encrypted zip with one file' do
      files = [ RapidftrAddon::ExportTask::Result.new("/1/2/3/file_1.pdf", "content 1") ]

      controller.should_receive(:send_file) do |file, opts|
        ZipRuby::Archive.open(file) do |ar|
          ar.num_files.should == 1
          ar.decrypt 'test_password'
          ar.fopen("file_1.pdf") do |f|
            f.read.should == "content 1"
          end
        end
      end

      controller.send(:encrypt_exported_files, files, nil)
    end

    it 'should send encrypted zip with multiple files' do
      files = [ RapidftrAddon::ExportTask::Result.new("/1/2/3/file_1.pdf", "content 1"), RapidftrAddon::ExportTask::Result.new("file_2.xls", "content 2") ]

      controller.should_receive(:send_file) do |file, opts|
        ZipRuby::Archive.open(file) do |ar|
          ar.num_files.should == 2
          ar.decrypt 'test_password'
          ar.fopen("file_1.pdf") do |f|
            f.read.should == "content 1"
          end
          ar.fopen("file_2.xls") do |f|
            f.read.should == "content 2"
          end
        end
      end

      controller.send(:encrypt_exported_files, files, nil)
    end

    it 'should send proper filename to the browser' do
      CleansingTmpDir.stub! :temp_file_name => 'encrypted_file'
      ZipRuby::Archive.stub! :open => true

      controller.should_receive(:send_file).with('encrypted_file', hash_including(:filename => 'test_filename.zip', :type => 'application/zip', :disposition => "inline"))
      controller.encrypt_exported_files [], 'test_filename.zip'
    end
  end

end
