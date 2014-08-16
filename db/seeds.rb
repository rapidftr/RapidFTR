# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed.

# Please keep the seeding idempotent, as it may be used as a migration if upgrading a production
# instance is necessary and the target version has introduced any new types requiring seeds.
def should_seed? model
  empty = model.database.documents["rows"].count == 0
  puts(empty ? "Seeding #{model}." : "Not seeding #{model}. Already populated.")
  empty
end

def should_seed_env_data?
  Rails.env.development? || Rails.env.test?
end

if should_seed? User
  registration_worker = Role.create!(:name => "registration worker", :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:register], Permission::CHILDREN[:edit], Permission::ENQUIRIES[:create], Permission::ENQUIRIES[:update]])
  registration_officer = Role.create!(:name => "registration officer", :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:register], Permission::CHILDREN[:edit], Permission::CHILDREN[:export], Permission::REPORTS[:view], Permission::ENQUIRIES[:create], Permission::ENQUIRIES[:update]])
  child_protection_specialist = Role.create!(:name => "child protection specialist", :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:register], Permission::CHILDREN[:edit], Permission::CHILDREN[:export], Permission::REPORTS[:view], Permission::USERS[:view]])
  senior_official = Role.create!(:name => "senior official", :permissions => [Permission::REPORTS[:view]])
  field_level_admin = Role.create!(:name => "field level admin", :permissions => [Permission::USERS[:create_and_edit], Permission::USERS[:view], Permission::USERS[:destroy], Permission::USERS[:disable], Permission::ROLES[:view], Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:export], Permission::REPORTS[:view], Permission::ENQUIRIES[:create], Permission::ENQUIRIES[:update]])
  system_admin = Role.create!(:name => "system admin", :permissions => [Permission::USERS[:create_and_edit], Permission::USERS[:view], Permission::USERS[:destroy], Permission::USERS[:disable], Permission::ROLES[:create_and_edit], Permission::ROLES[:view], Permission::REPORTS[:view], Permission::FORMS[:manage], Permission::SYSTEM[:highlight_fields], Permission::SYSTEM[:system_users], Permission::DEVICES[:blacklist], Permission::DEVICES[:replications]])

  User.create!("user_name" => "rapidftr",
               "password" => "rapidftr",
               "password_confirmation" => "rapidftr",
               "full_name" => "System Administrator",
               "email" => "rapidftr@rapidftr.com",
               "disabled" => "false",
               "organisation" => "N/A",
               "role_ids" => [system_admin.id])

  User.create!("user_name" => "field_worker",
               "password" => "field_worker",
               "password_confirmation" => "field_worker",
               "full_name" => "Field Worker",
               "email" => "field_worker@rapidftr.com",
               "disabled" => "false",
               "organisation" => "N/A",
               "role_ids" => [registration_worker.id])

  User.create!("user_name" => "field_admin",
               "password" => "field_admin",
               "password_confirmation" => "field_admin",
               "full_name" => "Field Administrator",
               "email" => "field_admin@rapidftr.com",
               "disabled" => "false",
               "organisation" => "N/A",
               "role_ids" => [field_level_admin.id])

  if Rails.env.android?
    User.create!("user_name" => "admin",
                 "password" => "admin" ,
                 "password_confirmation" => "admin",
                 "full_name" => "admin user",
                 "email" => "admin@rapidftr.com",
                 "disabled" => "false",
                 "organisation" => "Unicef",
                 "role_ids"=>[registration_worker.id,system_admin.id,field_level_admin.id])
  end
end

if should_seed? FormSection
  if should_seed_env_data?
    RapidFTR::ChildrenFormSectionSetup.reset_definitions
    RapidFTR::EnquiriesFormSectionSetup.reset_definitions
  else
    RapidFTR::ChildrenFormSectionSetup.reset_form
    RapidFTR::EnquiriesFormSectionSetup.reset_form
  end
  RapidFTR::I18nSetup.reset_definitions
end
