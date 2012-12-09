Before do
  Session.all.each {|s| s.destroy }
  Child.all.each {|c| c.destroy }
  Child.duplicates.each {|c| c.destroy }
  User.all.each {|u| u.destroy }
  Role.all.each {|role| role.destroy}
  SuggestedField.all.each {|u| u.destroy }
  ContactInformation.all.each {|c| c.destroy }
  RapidFTR::FormSectionSetup.reset_definitions
  Sunspot.remove_all!(Child)
  Sunspot.commit
end

Before('@roles') do |scenario|
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => [Permission::ADMIN[:admin]])
end

Before do
  GC.disable
end

After do
  GC.enable
  GC.start
end
