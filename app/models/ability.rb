class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :list, :to => :index
    alias_action :delete, :to => :destroy

    if user.has_permission?(Permission::LIMITED)
        can [ :index, :create ], Child
        can [ :read, :update, :destroy ], Child do |child|
          child.created_by == user.user_name
        end
    end

    if user.has_permission?(Permission::ACCESS_ALL_DATA)
      can [:manage, :read], Child
    end

    if user.has_permission?(Permission::ADMIN)
      can :manage, :all
    end
  end
end
