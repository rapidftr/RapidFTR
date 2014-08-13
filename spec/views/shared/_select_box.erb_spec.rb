require 'spec_helper'

describe 'shared/_select_box.html.erb', :type => :view do
  before :each do
    @child = Child.new('_id' => 'id12345', 'name' => 'First Last', 'new field' => '')
    assigns[:child] = @child
  end

  it 'should include image for tooltip when help text exists' do
    select_box = Field.new :name => 'new field',
                           :display_name => 'field name',
                           :type => 'select_box',
                           :option_strings => Array['M', 'F'],
                           :help_text => 'This is my help text'

    render :partial => 'shared/select_box', :locals => {:select_box => select_box, :model => @child}, :formats => [:html], :handlers => [:erb]
    expect(rendered).to have_tag('img.vtip')
  end

  it 'should not include image for tooltip when help text not exists' do
    select_box = Field.new :name => 'new field',
                           :display_name => 'field name',
                           :type => 'select_box',
                           :option_strings => Array['M', 'F']

    render :partial => 'shared/select_box', :locals => {:select_box => select_box, :model => @child}, :formats => [:html], :handlers => [:erb]
    expect(rendered).not_to have_tag('img.vtip')
  end

end
