require 'spec_helper'

describe Ability do

  before :each do
    @user = User.new :user_name => 'test'
    @session = Session.for_user(@user, "")
  end

  shared_examples "control class" do |clazz, result|
    before :each      do @ability = Ability.new(@session)               end

    it "list child"   do @ability.can?(:list, clazz).should == result   end
    it "create child" do @ability.can?(:create, clazz).should == result end
  end

  shared_examples "control object" do |object, result|
    before :each      do @ability = Ability.new(@session)                 end

    it "view object"   do @ability.can?(:read, object).should == result   end
    it "edit object"   do @ability.can?(:edit, object).should == result   end
    it "delete object" do @ability.can?(:delete, object).should == result end
  end

  shared_examples "control classes and objects" do |classes, result|
    classes.each do |clazz|
      include_examples "control class", clazz, result
      include_examples "control object", clazz.new, result
    end
  end

  describe '#admin' do
    before :each do @session.stub! :user_permissions => [ "admin" ] end

    include_examples "control classes and objects", [ Child, ContactInformation, Device, FormSection, Session, SuggestedField, User ], true
  end

  describe '#unlimited' do
    before :each do @session.stub! :user_permissions => [ "unlimited" ] end

    include_examples "control class", Child, true
    include_examples "control object", Child.new, true
    include_examples "control classes and objects", [ ContactInformation, Device, FormSection, Session, SuggestedField, User ], false
  end

  describe '#unlimited' do
    before :each do @session.stub! :user_permissions => [ "limited" ] end

    include_examples "control class", Child, true
    include_examples "control object", Child.new, false
    include_examples "control object", Child.new(:created_by => 'test'), true
    include_examples "control classes and objects", [ ContactInformation, Device, FormSection, Session, SuggestedField, User ], false
  end

end