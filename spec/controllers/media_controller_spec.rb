require 'spec_helper'
require 'support/child_builder'

describe MediaController, :type => :controller do
  include ChildBuilder
  include CustomMatchers
  include MiniMagickConversions

  before do
    fake_login
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

  describe 'response' do
    it "should return current child's photo" do
      given_a_child.
              with_id('1').
              with_photo(uploadable_photo, 'current')

      get :show_photo, :child_id => '1'
      expect(response).to redirect_to(:photo_id => 'current', :ts => Date.today)
    end

    it "should return requested child's photo" do
      given_a_child.
              with_id('1')
      with_photo(uploadable_photo, 'current').
      with_photo(uploadable_photo_jeff, 'other', false)

      get :show_photo, :child_id => '1', :photo_id => 'other'
      expect(response).to represent_inline_attachment(uploadable_photo_jeff)
    end

    it "should return current child's photo resized to a particular size" do
      given_a_child.
              with_id('1').
              with_photo(uploadable_photo, 'current')

      get :show_resized_photo, :child_id => '1', :size => 300
      expect(response).to redirect_to(:photo_id => 'current', :ts => Date.today)
    end

    it "should return current child's photo resized to a particular size" do
      given_a_child.
              with_id('1').
              with_photo(uploadable_photo, 'current')

      get :show_resized_photo, :child_id => '1', :photo_id => 'current', :size => 300
      expect(to_image(response.body)[:width]).to eq(300)
    end

    it "should return requested child's thumbnail" do
      given_a_child.
              with_id('1')
      with_photo(uploadable_photo_jeff).
              with_photo(uploadable_photo, 'other', false)

      get :show_thumbnail, :child_id => '1', :photo_id => 'other'

      thumbnail = to_thumbnail(160, uploadable_photo.original_filename)
      expect(response).to represent_inline_attachment(thumbnail)
    end

    it 'should return no photo available clip when no image is found' do
      given_a_child.
              with_id('1').
              with_no_photos

      get :show_photo, :child_id => '1'
      expect(response).to redirect_to(:photo_id => '_missing_')
    end

    it 'should return no photo available clip when no image is found' do
      given_a_child.
              with_id('1').
              with_no_photos

      get :show_photo, :child_id => '1', :photo_id => '_missing_'
      expect(response).to represent_inline_attachment(no_photo_clip)
    end

    it 'should redirect to proper cacheable URL if photo ID is not given' do
      given_a_child.
            with_id('1').
            with_photo(uploadable_photo_jeff).
            with_photo(uploadable_photo, 'other', false).
            with(:current_photo_key => 'test').
            with(:last_updated_at => 'test')

      get :show_thumbnail, :child_id => '1'
      expect(response).to redirect_to(:photo_id => 'test', :ts => 'test')
    end
  end

  describe 'download audio' do
    it 'should return an amr audio file associated with a child' do
      given_a_child.
              with_id('1').
              with_unique_identifier('child123').
              with_audio(uploadable_audio_amr)

      get :download_audio, :child_id => '1'
      expect(response).to represent_attachment(uploadable_audio_amr, 'audio_child123.amr')
    end
    it 'should return an mp3 audio file associated with a child' do
      given_a_child.
              with_id('1').
              with_unique_identifier('child123').
              with_audio(uploadable_audio_mp3)

      get :download_audio, :child_id => '1'
      expect(response).to represent_attachment(uploadable_audio_mp3, 'audio_child123.mp3')
    end
  end
end
