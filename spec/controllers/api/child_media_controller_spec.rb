require 'spec_helper'
require 'support/child_builder'

describe Api::ChildMediaController, :type => :controller do
  include ChildBuilder
  include CustomMatchers
  include MiniMagickConversions
  before do
    fake_login
  end

  describe "routing" do
    it "should have a route for a child current photo" do
      expect(:get => "/api/children/1/photo").to route_to(:controller => "api/child_media", :action => "show_photo", :id => "1")
    end

    it "should have a route for a child current recorded audio" do
      expect(:get => "api/children/1/audio").to route_to(:controller => "api/child_media", :action => "download_audio", :id => "1")
    end

    it "should have a route for a child current recorded audio" do
      expect(:get => "api/children/1/audio/a1").to route_to(:controller => "api/child_media", :action => "download_audio", :id => "1", :audio_id => "a1")
    end

    it "should have a route for a child specific photo" do
      expect(:get => "api/children/c1/photo/p1").to route_to(:controller => "api/child_media", :action => "show_photo", :id => "c1", :photo_id => "p1")
    end
  end

  describe '#send_photo_data' do
    it 'should add expires header if timestamp is supplied in query params' do
      controller.stub :send_data => nil
      controller.stub :params => {:ts => 'test'}
      expect(controller).to receive(:expires_in).with(1.year, :public => true)
      controller.send :send_photo_data
    end

    it 'should not add expires header for normal requests' do
      controller.stub :send_data => nil
      controller.stub :params => {}
      expect(controller).not_to receive(:expires_in)
      controller.send :send_photo_data
    end
  end

  describe "response" do
    it "should return current child's photo" do
      given_a_child.
              with_id("1").
              with_photo(uploadable_photo, 'current')

      get :show_photo, :id => "1"
      expect(response).to represent_inline_attachment(uploadable_photo)
    end

    it "should return requested child's photo" do
      given_a_child.
              with_id("1")
      with_photo(uploadable_photo, "current").
      with_photo(uploadable_photo_jeff, "other", false)

      get :show_photo, :id => "1", :photo_id => "other"
      expect(response).to represent_inline_attachment(uploadable_photo_jeff)
    end

    it "should return no photo available clip when no image is found" do
      given_a_child.
              with_id("1").
              with_no_photos

      get :show_photo, :id => "1", :photo_id => '_missing_'
      expect(response).to represent_inline_attachment(no_photo_clip)
    end
  end

  describe "download audio" do
    it "should return an amr audio file associated with a child" do
      given_a_child.
              with_id('1').
              with_unique_identifier('child123').
              with_audio(uploadable_audio_amr)

      get :download_audio, :id => '1'
      expect(response).to represent_attachment(uploadable_audio_amr, "audio_child123.amr")
    end
    it "should return an mp3 audio file associated with a child" do
      given_a_child.
              with_id('1').
              with_unique_identifier('child123').
              with_audio(uploadable_audio_mp3, "other")

      get :download_audio, :id => '1', :audio_id => "other"
      expect(response).to represent_attachment(uploadable_audio_mp3, "audio_child123.mp3")
    end
  end
end
