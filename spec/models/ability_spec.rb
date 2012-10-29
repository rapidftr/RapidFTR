require 'spec_helper'

describe Ability do

  before :each do
    @user = User.new :user_name => 'test'
  end

  shared_examples "control classes and objects" do |classes, result|
    before :each do
      @ability = Ability.new(@user)
    end

    classes.each do |clazz|
      it "list child" do
        @ability.can?(:index, clazz).should == result
      end
      it "create child" do
        @ability.can?(:create, clazz).should == result
      end
      it "view object" do
        @ability.can?(:read, clazz.new).should == result
      end
      it "edit object" do
        @ability.can?(:update, clazz.new).should == result
      end
    end
  end

  describe '#admin' do
    before :each do
      @user.stub!(:permissions => [Permission::ADMIN[:admin]])
    end

    include_examples "control classes and objects", [Child, ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], true
  end

  describe '#access all data' do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:access_all_data]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should have appropriate permissions" do
      ability = Ability.new(@user)
      ability.can?(:index, Child).should be_true
      ability.can?(:create, Child).should be_true
      ability.can?(:read, Child.new).should be_true
      ability.can?(:update, Child.new).should be_true
    end
  end

  describe '#register child' do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:register]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should have appropriate permissions" do
      ability = Ability.new(@user)
      ability.can?(:index, Child).should be_true
      ability.can?(:create, Child).should be_true
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
      ability.can?(:read, Child.new(:created_by => 'test')).should be_true
    end
  end

  describe '#view users' do
    it "it should view object" do
      @user.stub!(:permissions => [Permission::USERS[:view]])
      @ability = Ability.new(@user)
      @ability.can?(:list, User).should == true
      @ability.can?(:read, User.new).should == true
    end

    it "should not view object " do
      @user.stub!(:permissions => [Permission::CHILDREN[:register]])
      @ability = Ability.new(@user)
      @ability.can?(:list, User).should == false
      @ability.can?(:read, User.new).should == false
    end
    it "cannot update user " do
      @user.stub!(:permissions => [Permission::USERS[:view]])
      @ability = Ability.new(@user)
      @ability.can?(:update, User.new).should == false
      @ability.can?(:create, User.new).should == false
    end
  end
  describe '#edit child' do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:edit]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should have appropriate permissions" do
      ability = Ability.new(@user)
      ability.can?(:index, Child).should be_true
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
      ability.can?(:read, Child.new(:created_by => 'test')).should be_true
      ability.can?(:update, Child.new(:created_by => 'test')).should be_true
    end
  end

  describe '#create and edit users' do
    it "should be able to create users" do
      @user.stub!(:permissions => [Permission::USERS[:create_and_edit]])
      @ability = Ability.new(@user)
      @ability.can?(:create, User.new).should == true
      @ability.can?(:update, User.new).should == true
      @ability.can?(:destroy, User.new).should == false
    end
    it "should be able to view users" do
      @user.stub!(:permissions => [Permission::USERS[:create_and_edit]])
      @ability = Ability.new(@user)
      @ability.can?(:list, User).should == true
      @ability.can?(:read, User.new).should == true
    end
  end

  describe "destroy users" do
    it "should be able to delete users" do
      @user.stub!(:permissions => [Permission::USERS[:destroy]])
      @ability = Ability.new(@user)
      @ability.can?(:destroy, User.new).should == true
      @ability.can?(:read, User.new).should == true
      @ability.can?(:edit, User.new).should == false
    end
  end

  describe "disable users" do
    it "should be able to disable users" do
      @user.stub!(:permissions => [Permission::USERS[:disable]])
      @ability = Ability.new(@user)
      @ability.can?(:create, User.new).should == false
      @ability.can?(:update, User.new).should == true
      @ability.can?(:read, User.new).should == true
    end
  end


end
