# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed.

# Please keep the seeding idempotent, as it may be used as a migration if upgrading a production
# instance is necessary and the target version has introduced any new types requiring seeds.
def should_seed? model
  empty = model.all.empty?
  puts(empty ? "Seeding #{model}." : "Not seeding #{model}. Already populated.")
  empty
end

if should_seed? User
  admin = Role.create!(:name => "admin", :permissions => [Permission::ADMIN[:admin]])
  field_worker = Role.create!(:name => "field worker", :permissions => [Permission::CHILDREN[:register]])
  field_admin = Role.create!(:name => "field admin", :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create],
                                                                     Permission::CHILDREN[:edit]])
  User.create!("user_name" => "rapidftr",
              "password" => "rapidftr",
              "password_confirmation" => "rapidftr",
              "full_name" => "RapidFTR",
              "email" => "rapidftr@rapidftr.com",
              "disabled" => "false",
              "organisation" => "N/A",
              "role_ids" => [admin.id])

  User.create!("user_name" => "field_worker",
              "password" => "limited",
              "password_confirmation" => "limited",
              "full_name" => "RapidFTR",
              "email" => "limited@rapidftr.com",
              "disabled" => "false",
              "organisation" => "N/A",
              "role_ids" => [field_worker.id])

  User.create!("user_name" => "field_admin",
              "password" => "unlimited",
              "password_confirmation" => "unlimited",
              "full_name" => "RapidFTR",
              "email" => "unlimited@rapidftr.com",
              "disabled" => "false",
              "organisation" => "N/A",
              "role_ids" => [field_admin.id])
end

if should_seed? FormSection
  RapidFTR::FormSectionSetup.reset_definitions
  RapidFTR::I18nSetup.reset_definitions
end

if should_seed? SuggestedField
  RapidFTR::SuggestedFieldsSetup.reset_definitions
end

if should_seed? ContactInformation
  ContactInformation.create(:id=>"administrator")
end
