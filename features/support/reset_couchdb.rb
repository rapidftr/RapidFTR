Before do
  Session.all.each {|s| s.destroy }
  Child.all.each {|c| c.destroy }
  User.all.each {|u| u.destroy }
  FormSectionDefinition.all.each {|u| u.destroy }
  SuggestedField.all.each {|u| u.destroy }
end
