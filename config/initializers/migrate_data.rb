migrations_dir = "db/migration"

Dir.new(Rails.root.join(migrations_dir)).entries.select{|file| file.ends_with?".rb"}.sort.each do |file|
 puts "Applying migration: #{file}"
 load(Rails.root.join(migrations_dir, file))
end
