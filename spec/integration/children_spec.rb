require 'spec_helper'
require 'support/couchdb_client_helper'

describe Child, :type => :request do
  include CouchdbClientHelper
  it 'should save a child in the database' do
    photo = uploadable_photo
    child = build_child('jdoe',
                        'name' => 'Dave',
                        'age' => '28',
                        'last_known_location' => 'London',
                        'photo' => photo)
    expect(child.save).to be_truthy
  end

  it 'should load an existing child record from the database' do
    photo = uploadable_photo
    child = build_child('jdoe',
                        'name' => 'Paul',
      'age' => '10',
      'last_known_location' => 'New York', 'photo' => photo)
    child.save

    child_from_db = Child.get(child.id)

    expect(child_from_db['name']).to eq('Paul')
    expect(child_from_db['age']).to eq('10')
    expect(child_from_db['last_known_location']).to eq('New York')
    expect(child_from_db.primary_photo).to match_photo uploadable_photo
  end

  it 'should persist multiple photo attachments' do
    mock_user = double(:organisation => 'UNICEF')
    allow(User).to receive(:find_by_user_name).with(anything).and_return(mock_user)
    allow(Clock).to receive(:now).and_return(Time.parse('Jan 20 2010 12:04:15'))
    child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo_jeff)

    created_child = Child.get(child.id)
    allow(Clock).to receive(:now).and_return(Time.parse('Feb 20 2010 12:04:15'))

    created_child.update_attributes :photo => uploadable_photo

    updated_child = Child.get(child.id)
    photo_keys = updated_child['photo_keys']
    verify_attachment(updated_child.media_for_key(photo_keys.first), uploadable_photo_jeff)
    verify_attachment(updated_child.media_for_key(photo_keys.last), uploadable_photo)
  end
end

private

def build_child(created_by, options = {})
  user = User.new(:user_name => created_by)
  Child.new_with_user_name user, options
end

def verify_attachment(attachment, uploadable_file)
  expect(attachment.content_type).to eq(uploadable_file.content_type)
  expect(attachment.data.size).to eq(uploadable_file.data.size)
end

def display_child_errors(errors)
  errors.values.each { |value| puts value }
end
