Before do
  Child.stub! :index_record => true, :reindex! => true, :build_solar_schema => true
  Sunspot.stub! :index => true, :index! => true
end

Before('@search') do
  Child.rspec_reset
  Sunspot.rspec_reset
  Sunspot.remove_all!(Child)
  Sunspot.remove_all!(Enquiry)
end

Before do
  I18n.locale = I18n.default_locale = :en

  CouchRestRails::Document.descendants.each do |model|
    docs = model.database.documents["rows"].map { |doc|
      { "_id" => doc["id"], "_rev" => doc["value"]["rev"], "_deleted" => true } unless doc["id"].include? "_design"
    }.compact
    RestClient.post "#{model.database.root}/_bulk_docs", { :docs => docs }.to_json, { "Content-type" => "application/json" } unless docs.empty?
  end

  RapidFTR::FormSectionSetup.reset_definitions
  migration = File.basename (Dir[Rails.root.join("db/migration").join "0010*.rb"].first)
  Migration.apply_migration(migration)
end

Before('@roles') do |scenario|
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end
