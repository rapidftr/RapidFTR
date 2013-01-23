require 'spec_helper'

describe Ability do

  CRUD = [ :index, :create, :view, :edit, :update, :destroy ]

  let(:permissions) { [] }
  let(:user) { stub_model User, :user_name => 'test', :permissions => permissions }

  subject { Ability.new user }

  context 'base behavior' do
    # Weird behavior warning:
    # We would expect:
    #   can :update, User do { |user| user.user_name == 'test' }
    # To be applicable *only* for users with user_name = 'test', i.e.
    #   can? :update, User.new(:user_name => 'test') # will be true
    # BUT it also returns true for the entire User class!
    #   can? :update, User == true!!
    # It is messing up life a bit, so it is here as a test
    describe '#class and object assumptions' do
      subject {
        ability = Object.new.extend CanCan::Ability
        ability.can :update, Child do |child|
          child.name == 'test'
        end
        ability.stub :user => user
        ability
      }

      it { should authorize :update, Child }
      it { should authorize :update, Child.new(:name => 'test') }
      it { should_not authorize :update, Child.new }
    end

    describe '#manage with exceptions patch' do
      subject {
        ability = Object.new.extend CanCan::Ability
        ability.can :manage, User, :except => [ :update, :disable ]
        ability.stub :user => user
        ability
      }

      it { should authorize_all [ :blah, :foo, :bar ], User }
      it { should_not authorize_any [ :update, :disable ], [ User, User.new ] }
    end

    describe '#edit my account' do
      let(:permissions) { [] }
      it { should_not authorize_any [:update, :show], User, User.new, User.new(:user_name => 'some_other_user') }
      it { should authorize :update, stub_model(User, :user_name => user.user_name) }
      it { should authorize :show, stub_model(User, :user_name => user.user_name) }
    end
  end

  context 'children' do
    describe '#view,search all data and edit' do
      let(:permissions) { [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:edit]] }

      it { should_not authorize_any CRUD, ContactInformation, Device, FormSection, Field, Session, SuggestedField, User, Role }

      it { should authorize :index, Child }
      it { should_not authorize :create, Child }
      it { should authorize :read, Child.new }
      it { should authorize :update, Child.new }
    end

    describe '#register child' do
      let(:permissions) { [Permission::CHILDREN[:register]] }

      it { should_not authorize_any CRUD, ContactInformation, Device, FormSection, Field, Session, SuggestedField, User, Role }

      it { should authorize :index, Child }
      it { should authorize :create, Child }
      it { should_not authorize :read, Child.new }
      it { should_not authorize :update, Child.new }
      it { should authorize :read, Child.new(:created_by => 'test') }
    end

    describe '#edit child' do
      let(:permissions) { [Permission::CHILDREN[:edit]] }

      it { should_not authorize_any CRUD, ContactInformation, Device, FormSection, Field, Session, SuggestedField, User, Role }

      it { should authorize :index, Child }
      it { should_not authorize :read, Child.new }
      it { should_not authorize :update, Child.new }
      it { should authorize :read, Child.new(:created_by => 'test') }
      it { should authorize :update, Child.new(:created_by => 'test') }
    end

    describe "export children to photowall" do
      let(:permissions) { [Permission::CHILDREN[:export]] }

      it { should_not authorize_any CRUD, ContactInformation, Device, FormSection, Field, Session, SuggestedField, User, Role }

      it { should authorize :export, Child }
      it { should_not authorize :index, Child }
      it { should_not authorize :read, Child.new }
      it { should_not authorize :update, Child.new }
    end

    describe "view and search child records" do
      let(:permissions) { [ Permission::CHILDREN[:view_and_search]] }

      it { should authorize :index, Child.new }
      it { should authorize :read, Child.new }
      it { should authorize :view_all, Child }
    end
  end

  context 'users' do
    describe '#view users' do
      let(:permissions) { [Permission::USERS[:view]] }

      it { should authorize :list, User }
      it { should authorize :read, User.new }
      it { should_not authorize :update, User.new }
      it { should_not authorize :create, User.new }
    end

    describe '#create and edit users' do
      let(:permissions) { [Permission::USERS[:create_and_edit]] }

      it { should authorize :create, User.new }
      it { should authorize :update, User.new }
      it { should authorize :edit, User.new }
      it { should_not authorize :destroy, User.new }
      it { should authorize :read, User.new }
    end

    describe "destroy users" do
      let(:permissions) { [Permission::USERS[:destroy]] }

      it { should authorize :destroy, User.new }
      it { should authorize :read, User.new }
      it { should_not authorize :edit, User.new }
    end

    describe "disable users" do
      let(:permissions) { [Permission::USERS[:disable]] }

      it { should_not authorize_any [:create, :update], User.new }
      it { should authorize :disable, User.new }
      it { should authorize :read, User.new }
    end

    describe "blacklist" do
      let(:permissions) { [Permission::DEVICES[:black_list]] }

      it { should_not authorize_any CRUD, Child, ContactInformation, FormSection, Session, SuggestedField, User, Role, Replication }

      it { should authorize :update, Device }
      it { should authorize :index, Device }
      it { should_not authorize :read, User.new }
    end

    describe "replication" do
      let(:permissions) { [Permission::DEVICES[:replications]] }

      it { should_not authorize_any CRUD, Child, ContactInformation, FormSection, Session, SuggestedField, User, Role }

      it { should authorize :update, Replication }
      it { should_not authorize :read, User.new }
      it { should_not authorize :manage, Device }
    end
  end

  context 'roles' do
    describe "view roles permission" do
      let(:permissions) { [Permission::ROLES[:view]] }

      it { should authorize :list, Role.new }
      it { should authorize :view, Role.new }
      it { should_not authorize :create, Role.new }
      it { should_not authorize :update, Role.new }
    end

    describe "create and edit roles permission" do
      let(:permissions) { [Permission::ROLES[:create_and_edit]] }

      it { should authorize :list, Role.new }
      it { should authorize :create, Role.new }
      it { should authorize :update, Role.new }
    end
  end

  context 'forms' do
    describe "manage forms" do
      let(:permissions) { [Permission::FORMS[:manage]] }

      it { should_not authorize_any CRUD, Child, ContactInformation, Device, Session, SuggestedField, User, Role }

      it { should authorize :manage, FormSection.new }
      it { should authorize :manage, Field.new }
      it { should_not authorize :highlight, Field }
    end

    describe "highlight fields" do
      let(:permissions) { [Permission::SYSTEM[:highlight_fields]] }
      it { should_not authorize_any CRUD, Child, ContactInformation, Device, Session, SuggestedField, User, Role, FormSection, Field }
      it { should authorize :highlight, Field }
    end
  end

  describe "replications" do
    let(:permissions) { [Permission::SYSTEM[:replications]] }
    it { should_not authorize_any CRUD, Child, ContactInformation, Device, Session, SuggestedField, User, Role, FormSection, Field }
    it { should authorize :manage, Replication }
  end

  context 'other' do
    describe "system settings" do
      let(:permissions) { [Permission::SYSTEM[:settings]] }
      it { should_not authorize_any CRUD, Child, Device, Session, SuggestedField, User, Role, FormSection, Field }
      it { should authorize :manage, ContactInformation }
    end
  end

end
