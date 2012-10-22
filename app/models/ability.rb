class Ability
  include CanCan::Ability

  def initialize(session)
    alias_action :list, :to => :index
    alias_action :delete, :to => :destroy

    if session.has_permission?(Permission::LIMITED)
        can [ :index, :create ], Child
        can [ :read, :update, :destroy ], Child do |child|
          child.created_by == session.user_name
        end
    end

    if session.has_permission?(Permission::ACCESS_ALL_DATA)
      can :manage, Child
    end

    if session.has_permission?(Permission::ADMIN)
      can :manage, :all
    end
  end
end
