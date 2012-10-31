class Ability
  include CanCan::Ability

  def initialize(user)

    if user.has_permission?(Permission::CHILDREN[:register])
      can [:index, :create], Child
      can [:read], Child do |child|
        child.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::CHILDREN[:edit])
      can [:index], Child
      can [:read, :update], Child do |child|
        child.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::CHILDREN[:access_all_data])
      can :manage, Child
    end

    if user.has_permission?(Permission::CHILDREN[:export])
      can :export, Child
    end

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
    end

    if user.has_permission?(Permission::DEVICES[:black_list])
      can [:read,:update], Device
    end

    if user.has_permission?(Permission::ADMIN[:admin])
      can :manage, :all
    end

  end
end
