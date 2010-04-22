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

SuggestedField.create!("name"=>"Sample suggested field", "unique_id"=> "field_1", "description"=>"This is a useful field", :is_used=>"false", "field"=> Field.new(:name=>"theField", :type=>"TEXT"))
SuggestedField.create!("name"=>"Another suggested field", "unique_id"=> "field_2", "description"=>"This is a useful field", :is_used=>"false", "field"=> Field.new(:name=>"theSecondField", :type=>"radio_button"))
