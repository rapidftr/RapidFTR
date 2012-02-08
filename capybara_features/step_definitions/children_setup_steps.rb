require 'spec/spec_helper'

Given /^the following children exist in the system:$/ do |children_table|
  children_table.hashes.each do |child_hash|
    child_hash.reverse_merge!(
            'birthplace' => 'Cairo',
            'photo_path' => 'features/resources/jorge.jpg',
            'reporter' => 'zubair',
						'created_by' => 'Billy',
            'age_is' => 'Approximate',
            'flag' => false,
            'duplicate' => false
    )
    
    flag, flag_message = child_hash.delete('flag'), child_hash.delete('flag_message')
    
    photo = uploadable_photo(child_hash.delete('photo_path')) if child_hash['photo_path'] != ''
    unique_id = child_hash.delete('unique_id')
    child = Child.new_with_user_name(child_hash['created_by'], child_hash)
    child.photo = photo
    child['unique_identifier'] = unique_id if unique_id
    child.create!
    
    if flag
      child['flag'] = flag
      child['flag_message'] = flag_message
      child.save!
    end
  end
end

Given /^someone has entered a child with the name "([^\"]*)"$/ do |child_name|
  visit path_to('new child page')
  fill_in('Name', :with => child_name)
  fill_in('Birthplace', :with => 'Haiti')
  click_button('Save')
end