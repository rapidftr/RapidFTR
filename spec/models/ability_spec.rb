require 'spec_helper'

describe Ability do

  before :each do
    @user = User.new :user_name => 'test'
    @session = Session.for_user(@user, "")
  end
  
  shared_examples "control classes and objects" do |classes, result|
    before :each do @ability = Ability.new(@session) end
    
    classes.each do |clazz|
      it "list child"   do @ability.can?(:index, clazz).should == result  end
      it "create child" do @ability.can?(:create, clazz).should == result end
      it "view object"   do @ability.can?(:read, clazz.new).should == result    end
      it "edit object"   do @ability.can?(:update, clazz.new).should == result    end
    end
  end

  describe '#admin' do
    before :each do 
      @session.stub! :user => mock(:permissions => [ Permission::ADMIN])
      end

    include_examples "control classes and objects", [ Child, ContactInformation, Device, FormSection, Session, SuggestedField, User, Role ], true
  end

  describe '#access all data' do
    before :each do 
      @session.stub! :user => mock(:permissions => [ Permission::ACCESS_ALL_DATA])
    end
      
      include_examples "control classes and objects", [ ContactInformation, Device, FormSection, Session, SuggestedField, User, Role ], false

      it "should have appropriate permissions" do 
        ability = Ability.new(@session)
        ability.can?(:index, Child).should be_true
        ability.can?(:create, Child).should be_true
        ability.can?(:read, Child.new).should be_true
        ability.can?(:update, Child.new).should be_true
      end
  end

  describe '#register child' do
    before :each do 
      @session.stub! :user => mock(:permissions => [ Permission::REGISTER_CHILD])
    end

    include_examples "control classes and objects", [ ContactInformation, Device, FormSection, Session, SuggestedField, User, Role ], false

    it "should have appropriate permissions" do 
      ability = Ability.new(@session)
      ability.can?(:index, Child).should be_true
      ability.can?(:create, Child).should be_true
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
      ability.can?(:read, Child.new(:created_by => 'test')).should be_true
    end
  end

  describe '#edit child' do
    before :each do 
      @session.stub! :user => mock(:permissions => [ Permission::EDIT_CHILD])
    end
    
    include_examples "control classes and objects", [ ContactInformation, Device, FormSection, Session, SuggestedField, User, Role ], false
      
    it "should have appropriate permissions" do
      ability = Ability.new(@session)
      ability.can?(:index, Child).should be_true
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
      ability.can?(:read, Child.new(:created_by => 'test')).should be_true
      ability.can?(:update, Child.new(:created_by => 'test')).should be_true
    end
  end

end
