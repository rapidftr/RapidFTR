Before('@gc') do
  GC.enable
end

After do
  unless ENV["CI"] == "true"
    GC.enable
    GC.start
    GC.disable
  end
end

Before do
  I18n.locale = I18n.default_locale = :en

  CouchRestRails::Document.descendants.each do |model|
    model.all.each(&:destroy)
    model.duplicates.each(&:destroy) if model.respond_to?(:duplicates)
  end

  RapidFTR::FormSectionSetup.reset_definitions
  Sunspot.remove_all!(Child)
  Sunspot.commit
end

Before('@roles') do |scenario|
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end
