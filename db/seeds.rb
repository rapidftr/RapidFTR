# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed.

def should_seed? model
  empty = model.all.empty?
  puts(empty ? "Seeding #{model}." : "Not seeding #{model}. Already populated.")
  empty
end

if should_seed? User
  User.create("user_type" => "Administrator",
              "user_name" => "rapidftr",
              "password" => "rapidftr",
              "password_confirmation" => "rapidftr",
              "full_name" => "RapidFTR",
              "email" => "rapidftr@rapidftr.com")
end

if should_seed? FormSection
  RapidFTR::FormSectionSetup.reset_definitions
end

if should_seed? SuggestedField
  RapidFTR::SuggestedFieldsSetup.reset_definitions
end

if should_seed? ContactInformation
  ContactInformation.create(:id=>"administrator")
end
