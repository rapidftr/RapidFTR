require 'spec_helper'

describe Role, :type => :model do
  it "should not be valid if name is empty" do
    role = Role.new
    expect(role).not_to be_valid
    expect(role.errors[:name]).to eq(["Name must not be blank"])
  end

  it "should not be valid if permissions is empty" do
    role = Role.new
    expect(role).not_to be_valid
    expect(role.errors[:permissions]).to eq(["Please select at least one permission"])
  end

  it "should sanitize and check for permissions" do
    role = Role.new(:name => "Name", :permissions => [""]) #Need empty array, can't use %w here.
    expect(role).not_to be_valid
    expect(role.errors[:permissions]).to eq(["Please select at least one permission"])
  end

  it "should not be valid if a role name has been taken already" do
    Role.create({:name => "Unique", :permissions => Permission.all_permissions})
    role = Role.new({:name => "Unique", :permissions => Permission.all_permissions})
    expect(role).not_to be_valid
    expect(role.errors[:name]).to eq(["A role with that name already exists, please enter a different name"])
  end

  it "should titleize role name before validating it" do
    role = Role.new(:name => "should be titleized")
    role.valid?
    expect(role.name).to eq("Should Be Titleized")
  end

  it "should create a valid role" do
    expect(Role.new(:name => "some_role", :permissions => Permission.all_permissions)).to be_valid
  end

  it "should only grant permissions that are assigned to a role" do
    role = Role.new(:name => "some_role", :permissions => [Permission::CHILDREN[:register]])
    role.valid?
    expect(role.has_permission(Permission::CHILDREN[:register])).to eq(true)
    expect(role.has_permission(Permission::CHILDREN[:edit])).to eq(false)
  end

  it "should generate id" do
    Role.all.each { |role| role.destroy }
    role = create :role, :name => 'test role 1234', :_id => nil
    expect(role.id).to eq("role-test-role-1234")
  end
end
