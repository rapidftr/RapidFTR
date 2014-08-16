basic_identity_form_section = FormSection.by_unique_id(:key => "basic_identity").first
existing_ftr_status_field = basic_identity_form_section.fields.find{ |field| field[:display_name_en] == "FTR Status" }

if existing_ftr_status_field
  old_name = existing_ftr_status_field.name
  if old_name != "ftr_status"
    children_docs = Child.database.documents["rows"].select{ |row| !row["id"].include?("_design") }
    children_docs.each do |child_doc|
      child = Child.database.get child_doc["id"]
      child["ftr_status"] = child.delete old_name
      child.save
    end

    existing_ftr_status_field.name = "ftr_status"
    basic_identity_form_section.save!
  end
else
  basic_identity_form_section.fields << Field.new("name" => "ftr_status", "display_name" => "FTR Status", "type" => "select_box", "option_strings_text" => "Identified\nVerified\nTracing On-Going\nFamily Located Cross-Border FR Pending\nFamily Located Inter-Camp FR Pending\nReunited\nExported to CPIMS\nRecord Invalid","highlight_information"=>HighlightInformation.new("highlighted"=>true,"order"=>4))
  basic_identity_form_section.save!
end
