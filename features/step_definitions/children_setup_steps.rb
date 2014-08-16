Given /^the following children exist in the system:$/ do |children_table|
  children_table.hashes.each do |child_hash|
    create_child(child_hash)
  end
end

Given /^someone has entered a child with the name "([^\"]*)"$/ do |child_name|
  new_child_page.visit_page
  new_child_page.enter_details(child_name, 'Haiti')
  new_child_page.save
end

Given /^"([^\"]*)" is a duplicate of "([^\"]*)"$/ do |duplicate_name, parent_name|
  duplicate = Child.by_name(:key => duplicate_name).first
  parent = Child.by_name(:key => parent_name).first
  duplicate.mark_as_duplicate(parent['short_id'])
  duplicate.save
end

Then /^the form section "([^"]*)" should be (present|hidden)$/ do |form_section, visibility|
  if visibility == 'hidden'
    new_child_page.section_should_not_be_visible(form_section)
  else
    new_child_page.section_should_be_visible(form_section)
  end
end

private

def child_defaults
  {
    'birthplace' => 'Cairo',
    'photo_path' => 'capybara_features/resources/jorge.jpg',
    'reporter' => 'zubair',
    'created_by' => 'Billy',
    'created_organisation' => 'UNICEF',
    'age_is' => 'Approximate',
    'flag_message' => 'Reason for flagging',
    'flagged_at' => DateTime.new(2001, 2, 3, 4, 5, 6),
    'reunited_at' => DateTime.new(2012, 2, 3, 4, 5, 6)
  }
end

def create_child(child_hash)
  child_hash.reverse_merge!(child_defaults)

  user_name = child_hash['created_by']
  user = data_populator.ensure_user_exists(user_name)

  if child_hash['duplicate'] == 'true'
    child_hash.reverse_merge!('duplicate_of' => '123')
  else
    child_hash.delete('duplicate')
  end

  if child_hash['created_organisation']
    user.update_attributes({:organisation => child_hash['created_organisation']})
  end

  child_hash['flag_at'] = child_hash['flagged_at'] || DateTime.new(2001, 2, 3, 4, 5, 6)
  child_hash['reunited_at'] = child_hash['reunited_at'] || DateTime.new(2012, 2, 3, 4, 5, 6)
  flag, flag_message = child_hash.delete('flag').to_s == 'true', child_hash.delete('flag_message')

  photo = uploadable_photo(child_hash.delete('photo_path')) if child_hash['photo_path'] != ''
  child_hash['unique_identifier'] = child_hash.delete('unique_id') if child_hash['unique_id']
  child_hash['_id'] = child_hash['unique_identifier'] if child_hash['unique_identifier']
  child = Child.new_with_user_name(user, child_hash)
  child.photo = photo
  child['histories'] << {'datetime' => child_hash['flag_at'], 'changes' => {'flag' => 'anything'}}
  child['histories'] << {'datetime' => child_hash['reunited_at'], 'changes' => {'reunited' => {'from' => nil, 'to' => 'true'}, 'reunited_message' => {'from' => nil, 'to' => 'some message'}}}

  child.create!
  # Need this because of how children_helper grabs flag_message from child history - cg
  if flag
    child['flag'] = flag
    child['flag_message'] = flag_message
    child.save!
  end
end

def data_populator
  DataPopulator.new
end

def new_child_page
  @_new_child_page ||= NewChildPage.new(Capybara.current_session)
end

