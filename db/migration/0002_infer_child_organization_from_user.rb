children_docs = Child.database.documents["rows"].select { |row| !row["id"].include?("_design") }

children_docs.each do |child_doc|
  child = Child.get child_doc["id"]
  child.save!
end
