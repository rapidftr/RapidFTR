require 'spec_helper'

describe 'FieldOption', :type => :model do

  describe 'HTML tag generation' do

    before :each do
      @field_name = 'is_age_exact'
      @option_name = 'Approximate'
      @field_option = FieldOption.new @field_name, @option_name
      @model = Child.new
    end

    it 'converts field and option names to a HTML tag names' do
      expect(@field_option.tag_name_attribute(@model)).to eq("child[#{@field_name}][#{@option_name}]")
    end

    it 'converts field and option names to a HTML tag IDs' do
      expect(@field_option.tag_id @model).to eq("child_#{@field_name}_#{@option_name.downcase}")
    end

  end

  describe 'FieldOption creation' do

    it 'has a factory method for creating all FieldOption objects for a given Field' do
      field_name = 'gender'
      options = %w(male female)
      model = Child.new
      field_options = FieldOption.create_field_options(field_name, options)

      expect(field_options[0].tag_name_attribute(model)).to eq('child[gender][male]')
      expect(field_options[1].tag_name_attribute(model)).to eq('child[gender][female]')
    end
  end
end
