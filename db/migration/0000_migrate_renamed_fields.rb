database = FormSection.database
form_sections = database.documents["rows"].select{|row| !row["id"].include?("_design")}

form_sections.each do |row|
	form_section = database.get(row["id"])
	form_section["visible"] = form_section["enabled"]
	form_section.except! "enabled"
	
	form_section["fields"].each do |field|
		field["visible"] = field["enabled"]
		field.except! "enabled"
	end
	form_section.save
end
