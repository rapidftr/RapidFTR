
# Before each scenario...
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
#  CouchRestRails::Tests.setup
end

Before('@roles') do |scenario|
  Role.create(:name => 'limited', :permissions => [Permission::LIMITED])
  Role.create(:name => 'unlimited', :permissions => [Permission::ACCESS_ALL_DATA])
  Role.create(:name => 'admin', :permissions => [Permission::ADMIN])
end
