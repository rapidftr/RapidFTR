Before do
  I18n.locale = I18n.default_locale = :en

  CouchRestRails::Document.descendants.each do |model|
    docs = model.database.documents["rows"].map { |doc|
      { "_id" => doc["id"], "_rev" => doc["value"]["rev"], "_deleted" => true } unless doc["id"].include? "_design"
    }.compact
    RestClient.post "#{model.database.root}/_bulk_docs", { :docs => docs }.to_json, { "Content-type" => "application/json" } unless docs.empty?
  end

  RapidFTR::FormSectionSetup.reset_definitions
  Sunspot.remove_all!(Child)
end

Before('@roles') do |scenario|
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end
