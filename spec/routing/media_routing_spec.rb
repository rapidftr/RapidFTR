require 'spec_helper'

describe MediaController, :type => :routing do

  shared_examples 'routing' do
    describe 'routing' do
      it 'should have a route for current photo' do
        expect(:get => "/#{model}/1/photo").to route_to(:controller => 'media', :action => 'show_photo', model_id.to_sym => '1')
      end

      it 'should have a route for current recorded audio' do
        expect(:get => "/#{model}/1/audio").to route_to(:controller => 'media', :action => 'download_audio', model_id.to_sym => '1')
      end

      it 'should have a route for specific photo' do
        expect(:get => "/#{model}/c1/photo/p1").to route_to(:controller => 'media', :action => 'show_photo', model_id.to_sym => 'c1', :photo_id => 'p1')
      end

      it 'should have a route for specific recorded audio' do
        expect(:get => "/#{model}/c1/audio").to route_to(:controller => 'media', :action => 'download_audio', model_id.to_sym => 'c1')
      end

      it 'should have a route for requesting a resized version of the current photo' do
        expect(:get => "/#{model}/c1/resized_photo/100").to route_to(:controller => 'media', :action => 'show_resized_photo', model_id.to_sym => 'c1', :size => '100')
      end

      it 'should have a route for specific thumbnail' do
        expect(:get => "/#{model}/c1/thumbnail/t1").to route_to(:controller => 'media', :action => 'show_thumbnail', model_id.to_sym => 'c1', :photo_id => 't1')
      end

      it 'recognizes thumbnail path with photo_id' do
        expect(:get => "#{model}/1/thumbnail/321").to route_to(
          :controller => 'media', :action => 'show_thumbnail', model_id.to_sym => '1', :photo_id => '321')
      end

      it 'recognizes thumbnail path without photo_id' do
        expect(:get => "#{model}/1/thumbnail").to route_to(
          :controller => 'media', :action => 'show_thumbnail', model_id.to_sym => '1')
      end
    end
  end

  describe 'child_media' do
    it_behaves_like 'routing' do
      let(:model) {'children'}
      let(:model_id) {'child_id'}
    end
  end

  describe 'enquiry_media' do
    it_behaves_like 'routing' do
      let(:model) {'enquiries'}
      let(:model_id) {'enquiry_id'}
    end
  end
end
