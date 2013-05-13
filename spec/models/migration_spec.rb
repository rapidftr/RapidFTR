require 'spec_helper'

describe Migration do
  it 'should return migration dir' do
    Migration.migration_dir.to_s.should == Rails.root.join(Migration::MIGRATIONS_DIR).to_s
  end

  it 'should list all migrations' do
    Dir.should_receive(:[]).with(Migration.migration_dir.join "*.rb").and_return([ "/1/2/04_migration.rb", "/1/2/02_migration.rb" ])
    Migration.all_migrations.should == [ "02_migration.rb", "04_migration.rb" ]
  end

  it 'should list pending migrations' do
    Migration.stub! :applied_migrations => [ 1, 2, 3 ], :all_migrations => [ 3, 4, 5 ]
    Migration.pending_migrations.should == [ 4, 5 ]
  end

  it 'should list applied migrations' do
    Migration.database.save_doc :name => '2_test'
    Migration.database.save_doc :name => '1_test'
    Migration.applied_migrations.should == [ "1_test", "2_test" ]
  end

  it 'should apply only pending migrations' do
    Migration.stub! :applied_migrations => [], :pending_migrations => [1, 2, 3], :puts => true
    Migration.should_receive(:apply_migration).with(1).ordered
    Migration.should_receive(:apply_migration).with(2).ordered
    Migration.should_receive(:apply_migration).with(3).ordered
    Migration.migrate
  end

  it 'should save migration name in database after applying' do
    Kernel.should_receive(:load).with(Migration.migration_dir.join "one").and_return(false)
    Migration.database.should_receive(:save_doc).with(:name => "one")
    Migration.apply_migration("one")
  end
end
