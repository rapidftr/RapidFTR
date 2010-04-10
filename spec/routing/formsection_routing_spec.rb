require 'spec_helper'

describe 'Form Section routing' do

  it 'routes /formsections/foo/fields correctly' do
    {:get => '/formsections/foo/fields'}.should route_to(
      :controller => 'fields', :action => 'index', :formsection_id => 'foo' )
  end

  it 'has route to show form to create a new text_field field' do 
    {:get => '/formsections/foo/fields/new_text_field'}.should route_to(
      :controller => 'fields', :action => 'new_text_field', :formsection_id => 'foo' )
    new_text_field_formsection_fields_path('form_section_name').should ==
      '/formsections/form_section_name/fields/new_text_field'
  end

  it 'has route to show form to create a new select_drop_down field' do 
    {:get => '/formsections/foo/fields/new_select_drop_down'}.should route_to(
      :controller => 'fields', :action => 'new_select_drop_down', :formsection_id => 'foo' )
    new_select_drop_down_formsection_fields_path('form_section_name').should ==
      '/formsections/form_section_name/fields/new_select_drop_down'
  end

  it 'has route to post a new field' do
    { :post => '/formsections/foo/fields' }.should route_to(
      :controller => 'fields', :action => 'create', :formsection_id => 'foo' )
    formsection_fields_path('some_formsection').should ==
      '/formsections/some_formsection/fields'
  end
end
