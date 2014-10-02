require 'spec_helper'

describe Ability, :type => :model do

  CRUD = [:index, :create, :view, :edit, :update, :destroy]

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
      subject do
        ability = Object.new.extend CanCan::Ability
        ability.can :update, Child do |child|
          child.name == 'test'
        end
        ability.stub :user => user
        ability
      end

      it { is_expected.to authorize :update, Child }
      it { is_expected.to authorize :update, Child.new(:name => 'test') }
      it { is_expected.not_to authorize :update, Child.new }
    end

    describe '#manage with exceptions patch' do
      subject do
        ability = Object.new.extend CanCan::Ability
        ability.can :manage, User, :except => [:update, :disable]
        ability.stub :user => user
        ability
      end

      it { is_expected.to authorize_all [:blah, :foo, :bar], User }
      it { is_expected.not_to authorize_any [:update, :disable], [User, User.new] }
    end

    describe '#edit my account' do
      let(:permissions) { [] }
      it { is_expected.not_to authorize_any [:update, :show], User, User.new, User.new(:user_name => 'some_other_user') }
      it { is_expected.to authorize :update, stub_model(User, :user_name => user.user_name, :id => user.id) }
      it { is_expected.to authorize :show, stub_model(User, :user_name => user.user_name, :id => user.id) }
    end
  end

  context 'enquiries' do
    describe '#create enquiry' do
      let(:permissions) { [Permission::ENQUIRIES[:create]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Child }
      it { is_expected.to authorize :create, Enquiry }
      it { is_expected.not_to authorize :update, Enquiry.new }
      it { is_expected.to authorize :read, Enquiry }
    end

    describe '#update enquiry' do
      let(:permissions) { [Permission::ENQUIRIES[:update]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Child }
      it { is_expected.to authorize :update, Enquiry.new }
      it { is_expected.not_to authorize :create, Enquiry }
    end

    describe '#view enquiry' do
      let(:permissions) { [Permission::ENQUIRIES[:view]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Child }
      it { is_expected.not_to authorize :update, Enquiry.new }
      it { is_expected.not_to authorize :create, Enquiry }
      it { is_expected.to authorize :read, Enquiry }
    end
  end

  context 'potential_matches' do
    describe 'view' do
      let(:permissions) { [Permission::POTENTIAL_MATCHES[:read]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Child, Enquiry }
      it { is_expected.to authorize :read, PotentialMatch }
    end
  end

  context 'children' do
    describe '#view,search all data and edit' do
      let(:permissions) { [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:edit]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Enquiry }

      it { is_expected.to authorize :index, Child }
      it { is_expected.to authorize :view_and_search, Child }
      it { is_expected.not_to authorize :create, Child }
      it { is_expected.to authorize :read, Child.new }
      it { is_expected.to authorize :update, Child.new }
    end

    describe '#register child' do
      let(:permissions) { [Permission::CHILDREN[:register]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, Report }

      it { is_expected.to authorize :index, Child }
      it { is_expected.to authorize :create, Child }
      it { is_expected.not_to authorize :read, Child.new }
      it { is_expected.not_to authorize :update, Child.new }
      it { is_expected.to authorize :read, Child.new(:created_by => 'test') }
    end

    describe '#edit child' do
      let(:permissions) { [Permission::CHILDREN[:edit]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Enquiry }

      it { is_expected.to authorize :index, Child }
      it { is_expected.not_to authorize :read, Child.new }
      it { is_expected.not_to authorize :update, Child.new }
      it { is_expected.to authorize :read, Child.new(:created_by => 'test') }
      it { is_expected.to authorize :update, Child.new(:created_by => 'test') }
    end

    describe 'export children to photowall' do
      let(:permissions) { [Permission::CHILDREN[:export_photowall]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Enquiry }

      it { is_expected.to authorize :export_photowall, Child }
      it { is_expected.not_to authorize :index, Child }
      it { is_expected.not_to authorize :read, Child.new }
      it { is_expected.not_to authorize :update, Child.new }
      it { is_expected.not_to authorize :export_pdf, Child.new }
      it { is_expected.not_to authorize :export_cpims, Child.new }
      it { is_expected.not_to authorize :export_csv, Child.new }
    end

    describe 'export children to csv' do
      let(:permissions) { [Permission::CHILDREN[:export_csv]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Enquiry }

      it { is_expected.to authorize :export_csv, Child }
      it { is_expected.not_to authorize :index, Child }
      it { is_expected.not_to authorize :read, Child.new }
      it { is_expected.not_to authorize :update, Child.new }
      it { is_expected.not_to authorize :export_pdf, Child.new }
      it { is_expected.not_to authorize :export_cpims, Child.new }
      it { is_expected.not_to authorize :export_photowall, Child.new }
    end

    describe 'export children to pdf' do
      let(:permissions) { [Permission::CHILDREN[:export_pdf]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Enquiry }

      it { is_expected.to authorize :export_pdf, Child }
      it { is_expected.not_to authorize :index, Child }
      it { is_expected.not_to authorize :read, Child.new }
      it { is_expected.not_to authorize :update, Child.new }
      it { is_expected.not_to authorize :export_cpims, Child.new }
      it { is_expected.not_to authorize :export_csv, Child.new }
      it { is_expected.not_to authorize :export_photowall, Child.new }
    end

    describe 'export children to cpims' do
      let(:permissions) { [Permission::CHILDREN[:export_cpims]] }

      it { is_expected.not_to authorize_any CRUD, Device, FormSection, Field, Session, User, Role, SystemUsers, Report, Enquiry }

      it { is_expected.to authorize :export_cpims, Child }
      it { is_expected.not_to authorize :index, Child }
      it { is_expected.not_to authorize :read, Child.new }
      it { is_expected.not_to authorize :update, Child.new }
      it { is_expected.not_to authorize :export_pdf, Child.new }
      it { is_expected.not_to authorize :export_csv, Child.new }
      it { is_expected.not_to authorize :export_photowall, Child.new }
    end

    describe 'view and search child records' do
      let(:permissions) { [Permission::CHILDREN[:view_and_search]] }

      it { is_expected.to authorize :index, Child.new }
      it { is_expected.to authorize :read, Child.new }
      it { is_expected.to authorize :view_all, Child }
    end
  end

  context 'users' do
    describe '#view users' do
      let(:permissions) { [Permission::USERS[:view]] }

      it { is_expected.to authorize :list, User }
      it { is_expected.to authorize :read, User.new }
      it { is_expected.not_to authorize :update, User.new }
      it { is_expected.not_to authorize :create, User.new }
    end

    describe '#create and edit users' do
      let(:permissions) { [Permission::USERS[:create_and_edit]] }

      it { is_expected.to authorize :create, User.new }
      it { is_expected.to authorize :update, User.new }
      it { is_expected.to authorize :edit, User.new }
      it { is_expected.not_to authorize :destroy, User.new }
      it { is_expected.to authorize :read, User.new }
    end

    describe 'destroy users' do
      let(:permissions) { [Permission::USERS[:destroy]] }

      it { is_expected.to authorize :destroy, User.new }
      it { is_expected.to authorize :read, User.new }
      it { is_expected.not_to authorize :edit, User.new }
    end

    describe 'disable users' do
      let(:permissions) { [Permission::USERS[:disable]] }

      it { is_expected.not_to authorize_any [:create, :update], User.new }
      it { is_expected.to authorize :disable, User.new }
      it { is_expected.to authorize :read, User.new }
    end

    describe 'blacklist' do
      let(:permissions) { [Permission::DEVICES[:black_list]] }

      it { is_expected.not_to authorize_any CRUD, Child, FormSection, Session, User, Role, Replication, SystemUsers, Report }

      it { is_expected.to authorize :update, Device }
      it { is_expected.to authorize :index, Device }
      it { is_expected.not_to authorize :read, User.new }
    end

    describe 'replication' do
      let(:permissions) { [Permission::DEVICES[:replications]] }

      it { is_expected.not_to authorize_any CRUD, Child, FormSection, Session, User, Role, SystemUsers, Report }

      it { is_expected.to authorize :update, Replication }
      it { is_expected.not_to authorize :read, User.new }
      it { is_expected.not_to authorize :manage, Device }
    end
  end

  context 'roles' do
    describe 'view roles permission' do
      let(:permissions) { [Permission::ROLES[:view]] }

      it { is_expected.to authorize :list, Role.new }
      it { is_expected.to authorize :view, Role.new }
      it { is_expected.not_to authorize :create, Role.new }
      it { is_expected.not_to authorize :update, Role.new }
    end

    describe 'create and edit roles permission' do
      let(:permissions) { [Permission::ROLES[:create_and_edit]] }

      it { is_expected.to authorize :list, Role.new }
      it { is_expected.to authorize :create, Role.new }
      it { is_expected.to authorize :update, Role.new }
    end
  end

  context 'forms' do
    describe 'manage forms' do
      let(:permissions) { [Permission::FORMS[:manage]] }

      it { is_expected.not_to authorize_any CRUD, Child, Device, Session, User, Role, SystemUsers, Report }

      it { is_expected.to authorize :manage, FormSection.new }
      it { is_expected.to authorize :manage, Field.new }
      it { is_expected.not_to authorize :highlight, Field }
    end

    describe 'highlight fields' do
      let(:permissions) { [Permission::SYSTEM[:highlight_fields]] }
      it { is_expected.not_to authorize_any CRUD, Child, Device, Session, User, Role, FormSection, Field, SystemUsers, Report }
      it { is_expected.to authorize :highlight, Field }
    end
  end

  describe 'replications' do
    let(:permissions) { [Permission::DEVICES[:replications]] }
    it { is_expected.not_to authorize_any CRUD, Child, Device, Session, User, Role, FormSection, Field, SystemUsers, Report }
    it { is_expected.to authorize :manage, Replication }
  end

  describe 'reports' do
    let(:permissions) { [Permission::REPORTS[:view]] }
    it { is_expected.not_to authorize_any CRUD, Child, Device, Session, User, Role, FormSection, Field, SystemUsers, Replication }
    it { is_expected.to authorize :manage, Report }
  end

  context 'other' do
    describe 'system users for synchronisation' do
      let(:permissions) { [Permission::SYSTEM[:system_users]] }
      it { is_expected.not_to authorize_any CRUD, Child, Device, Session, User, Role, FormSection, Field }
      it { is_expected.to authorize :manage, SystemUsers }
    end

  end

end
