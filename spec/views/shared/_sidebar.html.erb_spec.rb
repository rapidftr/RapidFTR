require 'spec_helper'

describe 'shared/_sidebar.html.erb', :type => :view do

  before :each do
    reset_couchdb!
    form = create :form, :name => Enquiry::FORM_NAME
    form_section = create :form_section, :form => form, :name => 'basic_details', :fields => [build(:photo_field, :name => 'photo')]
    assign(:form_sections, [form_section])
    allow(User).to receive(:find_by_user_name).with('test_user').and_return(double(:organisation => 'stc'))
    @user = User.new
    @user.stub(:user_name => 'test_user')
    @user.stub(:permissions => [Permission::USERS[:create_and_edit], Permission::ENQUIRIES[:create], Permission::ENQUIRIES[:update], Permission::CHILDREN[:edit]])
    allow(controller).to receive(:current_user).and_return(@user)
  end

  it 'should display manage and edit photo links for child' do
    child = create :child, :photo => uploadable_photo_jeff, :created_by => @user.user_name
    assign :child, child
    render :template => 'shared/_sidebar.html.erb', :locals => {:model => child}
    expect(rendered).to have_tag('.profile-image .edit_photo')
    expect(rendered).to have_tag('.profile-image .manage_photo')
  end

  it 'should not display manage and edit photo links for enquiry' do
    enquiry = create :enquiry, :photo => uploadable_photo_jeff, :created_by => @user.user_name
    assign :enquiry, enquiry
    render :template => 'shared/_sidebar.html.erb', :locals => {:model => enquiry}
    expect(rendered).to_not have_tag('.profile-image .edit_photo')
    expect(rendered).to_not have_tag('.profile-image .manage_photo')
  end

  it 'should load enquiry photo given an enquiry' do
    enquiry = create :enquiry, :photo => uploadable_photo_jeff
    assign :enquiry, enquiry

    render :template => 'shared/_sidebar.html.erb', :locals => {:model => enquiry}

    expect(rendered).to have_tag('.profile-image') do
      with_tag('a[href=?]', resized_photo_path('enquiry', enquiry.id, enquiry.primary_photo_id, 640))
      with_tag('img[src=?]', resized_photo_path('enquiry', enquiry.id, enquiry.primary_photo_id, 328))
    end
  end

  it 'should load child photo given a child' do
    child = create :child, :photo => uploadable_photo_jeff
    assign :child, child

    render :template => 'shared/_sidebar', :locals => {:model => child}
    expect(rendered).to have_tag('.profile-image') do
      with_tag('a[href=?]', resized_photo_path('child', child.id, child.primary_photo_id, 640))
      with_tag('img[src=?]', resized_photo_path('child', child.id, child.primary_photo_id, 328))
    end
  end

  it 'should load empty image if the model has no photo' do
    child = build :child
    assign :child, child

    render :template => 'shared/_sidebar', :locals => {:model => child}

    expect(rendered).to have_tag('.profile-image') do
      with_tag('img[src=?]', 'no_photo_clip.jpg')
    end
  end
end
