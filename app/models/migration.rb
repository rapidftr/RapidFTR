class Migration < CouchRest::Model::Base
  use_database :migration

  MIGRATIONS_DIR = "db/migration"

  # WARNING: DO NOT Add any properties or anything to this class
  # We can't end up writing a migration for a migration class
  # Just use this class barebones, without any ORM, and use only migration-related methods here

  def self.migrate
    applied_migrations.each do |file|
      puts "skipping migration: #{file} - already applied" # rubocop:disable Output
    end

    pending_migrations.each do |file|
      puts "Applying migration: #{file}" # rubocop:disable Output
      apply_migration file
    end
  end

  def self.all_migrations
    Dir[migration_dir.join "*.rb"].map { |path| File.basename path }.sort
  end

  def self.applied_migrations
    migration_ids = database.documents["rows"].select { |row| !row["id"].include?("_design") }.map { |row| row["id"] }
    migration_ids.map { |id| database.get(id)[:name] }.sort
  end

  def self.pending_migrations
    all_migrations - applied_migrations
  end

  def self.migration_dir
    @@migration_dir ||= Rails.root.join MIGRATIONS_DIR
  end

  def self.apply_migration(file)
    lambda do
      Kernel.load migration_dir.join(file), true
    end.call
    database.save_doc :name => file
  end
end
