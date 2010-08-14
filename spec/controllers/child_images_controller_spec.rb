require 'spec_helper'
require 'support/child_builder'

describe ChildImagesController do
  include LoggedIn
  include ChildBuilder
  include CustomMatchers
  describe "routing" do
    it "should have a route for a child current photo" do
      { :get => "/children/1/photo" }.should route_to(:controller => "child_images", :action => "show_photo", :child_id => "1")
    end

    it "should have a route for a child specific photo" do
      { :get => "/children/c1/photo/p1" }.should route_to(:controller => "child_images", :action => "show_photo", :child_id => "c1", :id => "p1")
    end
    it "should have a route for a child current thumbnail" do
      {:get => '/children/1/thumbnail'}.should route_to(:controller => "child_images", :action => "show_thumbnail", :child_id => "1")
    end
    it "should have a route for a child specific thumbnail" do
      { :get => "/children/c1/thumbnail/t1" }.should route_to(:controller => "child_images", :action => "show_thumbnail", :child_id => "c1", :id => "t1")
    end
  end

  describe "response" do
    it "should return current child's photo" do
      given_a_child.
          with_id("1").
          with_photo(uploadable_photo)

      get :show_photo, :child_id => "1"

      response.should represent_inline_attachment uploadable_photo
    end

    it "should return requested child's photo" do
      given_a_child.
          with_id("1")
          with_photo(uploadable_photo, "current").
          with_photo(uploadable_photo_jeff, "other", false)

      get :show_photo, :child_id => "1", :id => "other"

      response.should represent_inline_attachment uploadable_photo_jeff
    end

    it "should return current child's thumbnail" do
      given_a_child.
          with_id("1")
          with_photo(uploadable_photo)

      get :show_thumbnail, :child_id => "1"

      thumbnail = to_thumbnail(60, uploadable_photo.original_path)
      response.should represent_inline_attachment thumbnail
    end

    it "should return requested child's thumbnail" do
      given_a_child.
          with_id("1")
          with_photo(uploadable_photo_jeff).
          with_photo(uploadable_photo, "other", false)

      get :show_thumbnail, :child_id => "1", :id => "other"

      thumbnail = to_thumbnail(60, uploadable_photo.original_path)
      response.should represent_inline_attachment thumbnail
    end

    it "should return no photo available clip when no image is found" do
      given_a_child.
          with_id("1")
          with_no_photos

      get :show_photo, :child_id => "1"

      response.should represent_inline_attachment no_photo_clip
    end
  end
end
