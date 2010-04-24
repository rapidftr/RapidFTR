require 'rapidftr_default_db_setup'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
User.create("user_type" => "Administrator",
            "user_name" => "rapidftr",
            "password" => "rapidftr",
            "password_confirmation" => "rapidftr",
            "full_name" => "RapidFTR",
            "email" => "rapidftr@rapidftr.com"
)

RapidFTR::DbSetup.reset_default_form_section_definitions

SuggestedField.create_from_field!(
        "Caregiver's name",
        "The name of the child's caregiver",
        Field.new("name" => "caregivers_name", "type" => "text_field"))

SuggestedField.create_from_field!(
        "Is an orphan",
        "Is the child an orphan",
        Field.new("name" => "is_orphan", "type" => "check_box"))


SuggestedField.create_from_field!(
        "Date of separation",
        "When the child was separated from his/her parents",
         Field.new("name" => "date_of_separation", "type" => "select_box", "option_strings" => ["", "1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"]))

SuggestedField.create_from_field!(
        "Gender",
        "The child's gender",
        Field.new("name" => "gender", "type" => "radio_button", "option_strings" => ["Male", "Female"]))



