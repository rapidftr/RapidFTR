require 'factory_girl'

FactoryGirl.define do
  factory :replication do
    description 'Sample Replication'
    host 'localhost'
    port 5984
    database_name 'replication_test'
  end
end
