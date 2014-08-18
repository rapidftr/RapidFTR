require 'spec_helper'

describe 'shared/_numeric_field.html.erb', :type => :view do
  before :each do
    @child = Child.new('_id' => 'id12345', 'name' => 'First Last', 'new field' => '')
    assigns[:child] = @child
  end

  it 'should include image for tooltip when help text when exists' do
    numeric_field = Field.new :name => 'new field',
                              :display_name => 'field name',
                              :type => 'numeric_field',
                              :help_text => 'This is my help text'

    render :partial => 'shared/numeric_field', :locals => {:numeric_field => numeric_field, :model => @child}, :formats => [:html], :handlers => [:erb]
    expect(rendered).to have_tag('img.vtip')
  end

  it 'should not include image for tooltip when help text not exists' do
    numeric_field = Field.new :name => 'new field',
                              :display_name => 'field name',
                              :type => 'numeric_field'

    render :partial => 'shared/numeric_field', :locals => {:numeric_field => numeric_field, :model => @child}, :formats => [:html], :handlers => [:erb]
    expect(rendered).not_to have_tag('img.vtip')
  end

end
