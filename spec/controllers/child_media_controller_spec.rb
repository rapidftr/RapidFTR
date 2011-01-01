require 'spec_helper'
require 'support/child_builder'

describe ChildMediaController do
  include ChildBuilder
  include CustomMatchers
  before do
    fake_login
  end
  describe "routing" do
    it "should have a route for a child current photo" do
      { :get => "/children/1/photo" }.should route_to(:controller => "child_media", :action => "show_photo", :child_id => "1")
    end

    it "should have a route for a child current recorded audio" do
      { :get => "/children/1/audio" }.should route_to(:controller => "child_media", :action => "download_audio", :child_id => "1")
    end

    it "should have a route for a child specific photo" do
      { :get => "/children/c1/photo/p1" }.should route_to(:controller => "child_media", :action => "show_photo", :child_id => "c1", :id => "p1")
    end

    it "should have a route for a child specific recorded audio" do
      { :get => "/children/c1/audio" }.should route_to(:controller => "child_media", :action => "download_audio", :child_id => "c1")
    end

    it "should have a route for requesting a resized version of the current photo" do
      {:get => '/children/c1/resized_photo/100'}.should route_to(:controller => "child_media", :action => "show_resized_photo", :child_id => "c1", :size => "100")
    end

    it "should have a route for a child current thumbnail" do
      {:get => '/children/1/thumbnail'}.should route_to(:controller => "child_media", :action => "show_thumbnail", :child_id => "1")
    end
    it "should have a route for a child specific thumbnail" do
      { :get => "/children/c1/thumbnail/t1" }.should route_to(:controller => "child_media", :action => "show_thumbnail", :child_id => "c1", :id => "t1")
    end
  end

  describe "response" do
    it "should return current child's photo" do
      given_a_child.
              with_id("1").
              with_photo(uploadable_photo)

      get :show_photo, :child_id => "1"

      response.should represent_inline_attachment(uploadable_photo)
    end

    it "should return requested child's photo" do
      given_a_child.
              with_id("1")
      with_photo(uploadable_photo, "current").
              with_photo(uploadable_photo_jeff, "other", false)

      get :show_photo, :child_id => "1", :id => "other"

      response.should represent_inline_attachment(uploadable_photo_jeff)
    end

    it "should return current child's photo resized to a particular size" do
      given_a_child.
              with_id("1").
              with_photo(uploadable_photo)

      get :show_resized_photo, :child_id => "1", :size => 300

      to_image(response.body)[:width].should == 300
    end

    it "should return current child's thumbnail" do
      given_a_child.
              with_id("1")
      with_photo(uploadable_photo)

      get :show_thumbnail, :child_id => "1"

      thumbnail = to_thumbnail(60, uploadable_photo.original_path)
      response.should represent_inline_attachment(thumbnail)
    end

    it "should return requested child's thumbnail" do
      given_a_child.
              with_id("1")
      with_photo(uploadable_photo_jeff).
              with_photo(uploadable_photo, "other", false)

      get :show_thumbnail, :child_id => "1", :id => "other"

      thumbnail = to_thumbnail(60, uploadable_photo.original_path)
      response.should represent_inline_attachment(thumbnail)
    end

    it "should return no photo available clip when no image is found" do
      given_a_child.
              with_id("1")
      with_no_photos

      get :show_photo, :child_id => "1"

      response.should represent_inline_attachment(no_photo_clip)
    end

  end

  describe "download audio" do
    it "should return a audio file associated with a child" do
        given_a_child.
                with_id('1').
                with_unique_identifier('child123').
                with_audio(uploadable_audio_amr)

       get :download_audio, :child_id => '1'
       response.should represent_attachment(uploadable_audio_amr, "audio_child123.amr")
    end
  end
end
