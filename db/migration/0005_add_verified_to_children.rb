children_docs = Child.database.documents["rows"].select { |row| !row["id"].include?("_design") }
children_docs.each do |child_doc|
  child = Child.database.get child_doc["id"]
  child["verified"] ||= true
  child.save
end
