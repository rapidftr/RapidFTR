class Ability
  include CanCan::Ability

  def initialize(user)
    
    if user.has_permission?(Permission::REGISTER_CHILD)
        can [:index, :create ], Child
        can [:read], Child do |child|
          child.created_by == user.user_name
        end
    end

    if user.has_permission?(Permission::EDIT_CHILD)
        can [:index], Child
        can [:read, :update], Child do |child|
          child.created_by == user.user_name
        end
    end

    if user.has_permission?(Permission::ACCESS_ALL_DATA)
      can [:manage], Child
    end

    if user.has_permission?(Permission::VIEW_USERS)
      can [:read,:show, :list], User
    end

    if user.has_permission?(Permission::CREATE_EDIT_USERS)
      can :manage, User
    end

    if user.has_permission?(Permission::ADMIN)
      can :manage, :all
    end
  end
end
