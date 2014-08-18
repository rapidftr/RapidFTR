require 'spec_helper'

describe 'shared/_text_field.html.erb', :type => :view do
  before :each do
    @child = Child.new('_id' => 'id12345', 'name' => 'First Last')
    assigns[:child] = @child
  end

  it 'should include image for tooltip when help text exists' do
    text_field = Field.new :name => 'new field',
                           :display_name => 'field name',
                           :type => 'text_field',
                           :help_text => 'This is my help text'

    render :partial => 'shared/text_field', :locals => {:text_field => text_field, :model => @child}, :formats => [:html], :handlers => [:erb]
    expect(rendered).to have_tag('img.vtip')

  end

  it 'should not include image for tooltip when help text not exists' do
    text_field = Field.new :name => 'new field',
                           :display_name => 'field name',
                           :type => 'text_field'

    render :partial => 'shared/text_field', :locals => {:text_field => text_field, :model => @child}, :formats => [:html], :handlers => [:erb]
    expect(rendered).not_to have_tag('img.vtip')
  end

end
