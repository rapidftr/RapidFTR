class Ability
  include CanCan::Ability

  def initialize(user)

    #
    # CHILDREN
    #
    if user.has_permission?(Permission::CHILDREN[:register])
      can [:index, :create], Child
      can [:read], Child do |child|
        child.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::CHILDREN[:edit])
      can [:index], Child
      can [:read, :update], Child do |child|
        (user.has_permission?(Permission::CHILDREN[:view_and_search]) || child.created_by == user.user_name)
      end
    end

    if user.has_permission?(Permission::CHILDREN[:view_and_search])
      can [:index, :read, :view_all], Child
    end

    if user.has_permission?(Permission::CHILDREN[:export])
      can :export, Child
    end

    #
    # USERS
    #
    if user.has_permission?(Permission::USERS[:view])
      can [:read, :show, :list], User
    end

    if user.has_permission?(Permission::USERS[:create_and_edit])
      can [:manage], User
      cannot [:update_disable_flag], User
      cannot [:destroy], User
    end

    if user.has_permission?(Permission::USERS[:destroy])
      can [:destroy, :read], User
    end

    if user.has_permission?(Permission::USERS[:disable])
      can [:update, :read], User
      can [:update_disable_flag], User
      cannot [:edit], User unless user.has_permission?(Permission::USERS[:create_and_edit])
    end

    #
    # DEVICES
    #
    if user.has_permission?(Permission::DEVICES[:black_list])
      can [:read,:update], Device
    end

    #
    # ROLES
    #
    if user.has_permission?(Permission::ROLES[:view])
      can [:list, :view], Role
    end

    if user.has_permission?(Permission::ROLES[:create_and_edit])
      can [:manage], Role
    end

    #
    # FORMS
    #
    if user.has_permission?(Permission::FORMS[:manage])
      can [:manage], FormSection
      can [:manage], Field
      cannot [:highlight], Field
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

    #
    # EVERYTHING AT ONCE
    #
    if user.has_permission?(Permission::ADMIN[:admin])
      can :manage, :all
    end
  end

end
