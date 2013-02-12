Before('@gc') do
  GC.enable
end

After do
  unless ENV["CI"] == true
    GC.enable
    GC.start
    GC.disable
  end
end

Before do
  Session.all.each { |o| o.destroy }
  Child.all.each { |o| o.destroy }
  Child.duplicates.each { |o| o.destroy }
  User.all.each { |o| o.destroy }
  Role.all.each { |o| o.destroy }
  SuggestedField.all.each { |o| o.destroy }
  ContactInformation.all.each { |o| o.destroy }

  RapidFTR::FormSectionSetup.reset_definitions
  Sunspot.remove_all!(Child)
  Sunspot.commit
end

Before('@roles') do |scenario|
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end
