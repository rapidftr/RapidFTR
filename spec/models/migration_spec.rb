require 'spec_helper'

describe Migration, :type => :model do
  it 'should return migration dir' do
    expect(Migration.migration_dir.to_s).to eq(Rails.root.join(Migration::MIGRATIONS_DIR).to_s)
  end

  it 'should list all migrations' do
    expect(Dir).to receive(:[]).with(Migration.migration_dir.join "*.rb").and_return([ "/1/2/04_migration.rb", "/1/2/02_migration.rb" ])
    expect(Migration.all_migrations).to eq([ "02_migration.rb", "04_migration.rb" ])
  end

  it 'should list pending migrations' do
    Migration.stub :applied_migrations => [ 1, 2, 3 ], :all_migrations => [ 3, 4, 5 ]
    expect(Migration.pending_migrations).to eq([ 4, 5 ])
  end

  it 'should list applied migrations' do
    Migration.database.save_doc :name => '2_test'
    Migration.database.save_doc :name => '1_test'
    expect(Migration.applied_migrations).to eq([ "1_test", "2_test" ])
  end

  it 'should apply only pending migrations' do
    Migration.stub :applied_migrations => [], :pending_migrations => [1, 2, 3], :puts => true
    expect(Migration).to receive(:apply_migration).with(1).ordered
    expect(Migration).to receive(:apply_migration).with(2).ordered
    expect(Migration).to receive(:apply_migration).with(3).ordered
    Migration.migrate
  end

  it 'should save migration name in database after applying' do
    expect(Kernel).to receive(:load).with(Migration.migration_dir.join("one"), true).and_return(false)
    expect(Migration.database).to receive(:save_doc).with(:name => "one")
    Migration.apply_migration("one")
  end
end
