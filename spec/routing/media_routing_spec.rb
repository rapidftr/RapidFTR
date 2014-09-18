require 'spec_helper'

describe MediaController, :type => :routing do

  describe 'routing' do
    it 'should have a route for a child current photo' do
      expect(:get => '/children/1/photo').to route_to(:controller => 'media', :action => 'show_photo', :child_id => '1')
    end

    it 'should have a route for a child current recorded audio' do
      expect(:get => '/children/1/audio').to route_to(:controller => 'media', :action => 'download_audio', :child_id => '1')
    end

    it 'should have a route for a child specific photo' do
      expect(:get => '/children/c1/photo/p1').to route_to(:controller => 'media', :action => 'show_photo', :child_id => 'c1', :photo_id => 'p1')
    end

    it 'should have a route for a child specific recorded audio' do
      expect(:get => '/children/c1/audio').to route_to(:controller => 'media', :action => 'download_audio', :child_id => 'c1')
    end

    it 'should have a route for requesting a resized version of the current photo' do
      expect(:get => '/children/c1/resized_photo/100').to route_to(:controller => 'media', :action => 'show_resized_photo', :child_id => 'c1', :size => '100')
    end

    it 'should have a route for a child specific thumbnail' do
      expect(:get => '/children/c1/thumbnail/t1').to route_to(:controller => 'media', :action => 'show_thumbnail', :child_id => 'c1', :photo_id => 't1')
    end

    it 'recognizes child thumbnail path with photo_id' do
      expect(:get => 'children/1/thumbnail/321').to route_to(
        :controller => 'media', :action => 'show_thumbnail', :child_id => '1', :photo_id => '321')
    end

    it 'recognizes child thumbnail path without photo_id' do
      expect(:get => 'children/1/thumbnail').to route_to(
        :controller => 'media', :action => 'show_thumbnail', :child_id => '1')
    end
  end
end
