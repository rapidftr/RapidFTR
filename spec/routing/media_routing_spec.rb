require 'spec_helper'

describe MediaController, :type => :routing do

  shared_examples 'routing' do
    describe 'routing' do
      it 'should have a route for manage photos' do
        expect(:get => "/#{model}/1/photos").to route_to(:controller => 'media', :action => 'manage_photos', :model_type => model, :model_id => '1')
      end

      it 'should have a route for specific photo' do
        expect(:get => "/#{model}/c1/photo/p1").to route_to(:controller => 'media', :action => 'show_photo', :model_type => model, :model_id => 'c1', :photo_id => 'p1')
      end

      it 'should have a route for resized photo' do
        expect(:get => "/#{model}/c1/photo/p1/resized/640").to route_to(:controller => 'media', :action => 'show_resized_photo', :model_type => model, :model_id => 'c1', :photo_id => 'p1', :size => '640')
      end

      it 'should have a route for specific thumbnail' do
        expect(:get => "/#{model}/c1/thumbnail/t1").to route_to(
          :controller => 'media', :action => 'show_thumbnail', :model_type => model, :model_id => 'c1', :photo_id => 't1')
      end

      it 'recognizes thumbnail path without photo_id' do
        expect(:get => "#{model}/1/thumbnail").to route_to(
          :controller => 'media', :action => 'show_thumbnail', :model_type => model, :model_id => '1')
      end

      it 'should have a route for current recorded audio' do
        expect(:get => "/#{model}/1/audio").to route_to(:controller => 'media', :action => 'download_audio', :model_type => model, :model_id => '1')
      end

      it 'should have a route for specific recorded audio' do
        expect(:get => "/#{model}/c1/audio/1").to route_to(:controller => 'media', :action => 'download_audio', :model_type => model, :model_id => 'c1', :id => '1')
      end
    end
  end

  describe 'legacy routing to support old Android APK' do
    it 'should a photos index route' do
      expect(:get => '/children/1/photos_index').to route_to(
        :controller => 'media', :action => 'index', :model_type => 'child', :model_id => '1')
    end

    it 'should have a route for current photo' do
      expect(:get => '/children/1/photo').to route_to(:controller => 'media', :action => 'show_photo', :model_type => 'child', :model_id => '1')
    end

    it 'should have a route for requesting a resized version of the current photo' do
      expect(:get => '/children/c1/resized_photo/100').to route_to(:controller => 'media', :action => 'show_resized_photo', :model_type => 'child', :model_id => 'c1', :size => '100')
    end
  end

  describe 'child_media' do
    it_behaves_like 'routing' do
      let(:model) { 'child' }
      let(:model_id) { 'child_id' }
    end
  end

  describe 'enquiry_media' do
    it_behaves_like 'routing' do
      let(:model) { 'enquiry' }
      let(:model_id) { 'enquiry_id' }
    end
  end
end
