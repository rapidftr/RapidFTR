require 'spec_helper'

describe ChildMediaController do
  describe "routing" do

    it 'recognizes child thumbnail path with photo_id' do
      {:get => 'children/1/thumbnail/321'}.should route_to(
        :controller => 'child_media', :action => 'show_thumbnail', :child_id => '1', :photo_id => '321')
    end

    it 'recognizes child thumbnail path without photo_id' do
      {:get => 'children/1/thumbnail'}.should route_to(
        :controller => 'child_media', :action => 'show_thumbnail', :child_id => '1')
    end
  end
end

