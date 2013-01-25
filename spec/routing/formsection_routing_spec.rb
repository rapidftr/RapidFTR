require 'spec_helper'

describe 'Form Section routing' do

  it 'routes /form_section/foo/fields correctly' do
    {:get => '/form_section/foo/fields'}.should route_to(
      :controller => 'fields', :action => 'index', :form_section_id => 'foo' )
  end

  it 'has route to post a new field' do
    {:post => '/form_section/foo/fields' }.should route_to(:controller => 'fields', :action => 'create', :form_section_id => 'foo' )
    form_section_fields_path('some_formsection').should == '/form_section/some_formsection/fields'
  end

  it 'has route to move a field up' do
    {:post => '/form_section/foo/fields/move_up'}.should route_to(:controller => 'fields', :action=>'move_up', :form_section_id=>'foo')
    move_up_form_section_fields_path('some_formsection').should == '/form_section/some_formsection/fields/move_up'
  end


  it 'has route to move a field down' do
    {:post => '/form_section/foo/fields/move_down'}.should route_to(:controller => 'fields', :action=>'move_down', :form_section_id=>'foo')
    move_down_form_section_fields_path('some_formsection').should == '/form_section/some_formsection/fields/move_down'
  end
  
  it 'has route for form sections index page' do
    {:get => '/form_sections'}.should route_to(:controller => 'form_section', :action=>'index')
    form_sections_path.should == '/form_sections'
  end

  it 'has route for form sections new page' do
    {:get => '/form_section/new'}.should route_to(:controller => 'form_section', :action=>'new')
    new_form_section_path.should == '/form_section/new'
  end

  it "has route for update field page" do
    {:put => '/form_section/form_section_unique_id/fields/field_id'}.should route_to(:controller => 'fields', :action => "update", "form_section_id"=>"form_section_unique_id", "id"=>"field_id")
  end
end