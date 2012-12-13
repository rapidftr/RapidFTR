Before do
  GC.disable
end

After do
  GC.enable
  GC.start
end

Before do
  Session.database.delete!
  Session.database.create!

  Child.database.delete!
  Child.database.create!

  User.database.delete!
  User.database.create!

  Role.database.delete!
  Role.database.create!

  SuggestedField.database.delete!
  SuggestedField.database.create!

  ContactInformation.database.delete!
  ContactInformation.database.create!

  RapidFTR::FormSectionSetup.reset_definitions
  Sunspot.remove_all!(Child)
  Sunspot.commit
end

Before('@roles') do |scenario|
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end

After do |scenario|
  if scenario.failed?
    begin
      encoded_img = page.driver.browser.screenshot_as(:base64)
      embed("data:image/png;base64,#{encoded_img}", 'image/png')
    rescue
      # ignore the error in taking screenshot as it does not affect test outcome
    end
  end
end
