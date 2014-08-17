date_of_separation = Field.new("name" => "date_of_separation", "type" => "date_field", "display_name_all" => "Date of Separation (dd/mm/yyyy)")

separation_history_fs = FormSection.by_unique_id(:key => "separation_history").first
separation_history_fs.fields << date_of_separation
separation_history_fs.save!

children_docs = Child.database.documents["rows"].select { |row| !row["id"].include?("_design") }
children_docs.each do |child_doc|
  child = Child.database.get child_doc["id"]

  begin
    separation_date = child[:separation_date]
    parsed_date = Chronic.parse(separation_date)
    parsed_date ||= Chronic.parse(separation_date + " ago")
    parsed_date ? parsed_date.strftime("%m-%d-%Y") : nil
    child[:date_of_separation] = parsed_date
    child.save!
  rescue
    nil
  end
end
