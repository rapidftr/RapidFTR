require 'factory_girl'

FactoryGirl.define do
  factory :replication do
    description 'Sample Replication'
    remote_url 'localhost:1234'
    user_name 'username'
    password 'password'
    after_build do |replication|
      replication.stub! :remote_config => { "target" => "localhost:5984/replication_test" }
    end
  end
end
