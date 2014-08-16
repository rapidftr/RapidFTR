require 'spec_helper'
describe SystemUsers, :type => :model do

  before :each do
    @sys_user = build :system_users
  end

  after :each do
    @sys_user.destroy
  end

  it "System Users should be valid" do
    expect(@sys_user).to be_valid
    @sys_user.save
  end

  it "should assign _id based on name" do
    @sys_user.save
    expect(@sys_user._id).to eq("org.couchdb.user:test_user")
  end

  it "should not save if the username already exists" do
    @sys_user.save
    another_sys_user = build :system_users
    expect { another_sys_user.save }.to raise_error
  end

  it "should fetch all the _user documents" do
    @sys_user.save
    expect(SystemUsers.get(@sys_user._id)).not_to be_nil
  end
end
