basic_identity_fs = FormSection.by_unique_id(:key => "basic_identity").first

unless basic_identity_fs.fields.any? { |f| f.name == 'date_of_birth' }
  dob_field = Field.new({"name" => "date_of_birth", "type" => "date_field", "display_name_all" => "Date of Birth (dd/mm/yyyy)"})

  basic_identity_fs.fields << dob_field
  basic_identity_fs.save!

  children_docs = Child.database.documents["rows"].select { |row| !row["id"].include?("_design") }
  children_docs.each do |child_doc|
    child = Child.database.get child_doc["id"]

    begin
      dob_or_age = child[:dob_or_age]
      dob = Chronic.parse(dob_or_age)
      dob ||= Chronic.parse(dob_or_age + " ago")
      dob ? dob.strftime("%m-%d-%Y") : nil
      child[:date_of_birth] = dob
      child.save!
    rescue
      nil
    end
  end
end
