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
  admin = Role.create(:name => "admin", :permissions => [Permission::ADMIN])
  limited = Role.create(:name => "limited", :permissions => [Permission::LIMITED])
  unlimited = Role.create(:name => "unlimited", :permissions => [Permission::ACCESS_ALL_DATA])
  User.create("user_name" => "rapidftr",
              "password" => "rapidftr",
              "password_confirmation" => "rapidftr",
              "full_name" => "RapidFTR",
              "email" => "rapidftr@rapidftr.com",
              "role_names" => [admin.name])

  User.create("user_name" => "limited",
              "password" => "limited",
              "password_confirmation" => "limited",
              "full_name" => "RapidFTR",
              "email" => "limited@rapidftr.com",
              "role_names" => [ limited.name ] )

  User.create("user_name" => "unlimited",
              "password" => "unlimited",
              "password_confirmation" => "unlimited",
              "full_name" => "RapidFTR",
              "email" => "unlimited@rapidftr.com",
              "role_names" => [ unlimited.name ] )
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
