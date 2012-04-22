
Before do
  Session.all.each {|s| s.destroy }
  Child.all.each {|c| c.destroy }
  Child.duplicates.each {|c| c.destroy }
  User.all.each {|u| u.destroy }
  SuggestedField.all.each {|u| u.destroy }
  ContactInformation.all.each {|c| c.destroy }
  RapidFTR::FormSectionSetup.reset_definitions
  Sunspot.remove_all!(Child)
  Sunspot.commit
end
