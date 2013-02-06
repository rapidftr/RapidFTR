class Ability
  include CanCan::Ability

  def user
    @user
  end

  def initialize(user)
    alias_action :index, :view, :list, :to => :read
    alias_action :edit, :to => :update

    @user = user

    #
    # CHILDREN
    #
    if user.has_permission?(Permission::CHILDREN[:register])
      can [:create], Child
      can [:read], Child do |child|
        child.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::CHILDREN[:edit])
      can [:read, :update, :destroy], Child do |child|
        child.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::CHILDREN[:view_and_search])
      can [:read, :view_all, :view_and_search], Child
    end

    if user.has_permission?(Permission::CHILDREN[:view_and_search]) and user.has_permission?(Permission::CHILDREN[:edit])
      can [:read, :update, :destroy], Child
    end

    if user.has_permission?(Permission::CHILDREN[:export])
      can [:export], Child
    end

    #
    # USERS
    #

    # Can edit and see own details
    can [:read, :update], @user

    if user.has_permission?(Permission::USERS[:view])
      can [:read], User
    end

    if user.has_permission?(Permission::USERS[:create_and_edit])
      can [:manage], User, :except => [ :disable, :destroy ]
    end

    if user.has_permission?(Permission::USERS[:destroy])
      can [:destroy, :read], User
    end

    if user.has_permission?(Permission::USERS[:disable])
      can [:read, :disable], User
    end

    #
    # DEVICES
    #
    if user.has_permission?(Permission::DEVICES[:black_list])
      can [:read, :update], Device
    end

    #
    # ROLES
    #
    if user.has_permission?(Permission::ROLES[:view])
      can [:read], Role
    end

    if user.has_permission?(Permission::ROLES[:create_and_edit])
      can [:manage], Role
    end

    #
    # FORMS
    #
    if user.has_permission?(Permission::FORMS[:manage])
      can [:manage], FormSection
      can [:manage], Field, :except => :highlight
    end

    #
    # HIGHLIGHT FIELDS
    #
    if user.has_permission?(Permission::SYSTEM[:highlight_fields])
      can [:highlight], Field
    end

    #
    # SYSTEM SETTINGS
    #
    if user.has_permission?(Permission::SYSTEM[:settings])
      can [:manage], ContactInformation
    end
  end

  def can(action = nil, subject = nil, conditions = nil, &block)
    rules << CanCan::CustomRule.new(true, action, subject, conditions, block)
  end

  def cannot(action = nil, subject = nil, conditions = nil, &block)
    rules << CanCan::CustomRule.new(false, action, subject, conditions, block)
  end

end
