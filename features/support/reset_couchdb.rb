require 'rapidftr_default_db_setup'

Before do
  Session.all.each {|s| s.destroy }
  Child.all.each {|c| c.destroy }
  User.all.each {|u| u.destroy }
  SuggestedField.all.each {|u| u.destroy }
  ContactInformation.all.each {|c| c.destroy }
  RapidFTR::DbSetup.reset_default_form_section_definitions
  Sunspot.remove_all!(Child)
  Sunspot.commit
end
