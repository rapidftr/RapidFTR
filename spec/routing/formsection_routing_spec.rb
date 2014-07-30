require 'spec_helper'

describe 'Form Section routing', :type => :routing do

  it 'routes /form_section/foo/fields correctly' do
    expect({:get => '/form_section/foo/fields'}).to route_to(
      :controller => 'fields', :action => 'index', :form_section_id => 'foo' )
  end

  it 'has route to post a new field' do
    expect({:post => '/form_section/foo/fields' }).to route_to(:controller => 'fields', :action => 'create', :form_section_id => 'foo' )
    expect(form_section_fields_path('some_formsection')).to eq('/form_section/some_formsection/fields')
  end

  it 'has route to save order of fields' do
    expect({:post => '/form_section/foo/fields/save_order'}).to route_to(:controller => 'fields', :action=>'save_order', :form_section_id=>'foo')
    expect(save_order_form_section_fields_path('some_formsection')).to eq('/form_section/some_formsection/fields/save_order')
  end

  it 'has route for form sections index page' do
    expect({:get => 'forms/foo/form_section'}).to route_to(:controller => 'form_section', :action=>'index', :form_id => 'foo')
    expect(form_form_sections_path('foo')).to eq('/forms/foo/form_section')
  end

  it 'has route for form sections new page' do
    expect({:get => 'forms/foo/form_section/new'}).to route_to(:controller => 'form_section', :action=>'new', :form_id => 'foo')
    expect(new_form_form_section_path('foo')).to eq('/forms/foo/form_section/new')
  end

  it "has route for update field page" do
    expect({:put => '/form_section/form_section_unique_id/fields/field_id'}).to route_to(:controller => 'fields', :action => "update", "form_section_id"=>"form_section_unique_id", "id"=>"field_id")
  end

  it "redirects /published_form_sections to the new API controller" do
    expect({ :get => '/published_form_sections' }).to route_to(:controller => 'api/form_sections', :action => 'children')
    expect({ :get => '/published_form_sections.json' }).to route_to(:controller => 'api/form_sections', :action => 'children', :format => 'json')
  end
end
