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

    if user.has_permission?(Permission::CHILDREN[:view_and_search]) && user.has_permission?(Permission::CHILDREN[:edit])
      can [:read, :update, :destroy], Child
    end

    if user.has_permission?(Permission::CHILDREN[:export_csv])
      can [:export_csv], Child
    end
    if user.has_permission?(Permission::CHILDREN[:export_photowall])
      can [:export_photowall], Child
    end
    if  user.has_permission?(Permission::CHILDREN[:export_pdf])
      can [:export_pdf], Child
    end
    if  user.has_permission?(Permission::CHILDREN[:export_cpims])
      can [:export_cpims], Child
    end
    if  user.has_permission?(Permission::CHILDREN[:export_mock])
      can [:export_mock], Child
    end

    #
    # ENQUIRIES
    #

    if user.has_permission?(Permission::ENQUIRIES[:create])
      can [:create], Enquiry do |enquiry|
        enquiry.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::ENQUIRIES[:update])
      can [:update, :read], Enquiry
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
      can [:manage], User, :except => [:disable, :destroy]
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

    if user.has_permission?(Permission::DEVICES[:replications])
      can [:manage], Replication
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
    # REPLICATIONS
    #
    if user.has_permission?(Permission::DEVICES[:replications])
      can [:manage], Replication
    end

    #
    # SYSTEM SETTINGS
    #
    # SYNCHRONISATION USERS
    if user.has_permission?(Permission::SYSTEM[:system_users])
      can [:manage], SystemUsers
    end

    # HIGHLIGHT FIELDS
    if user.has_permission?(Permission::SYSTEM[:highlight_fields])
      can [:highlight], Field
    end

    # REPORTS
    if user.has_permission?(Permission::REPORTS[:view])
      can [:manage], Report
    end

  end

  def can(action = nil, subject = nil, conditions = nil, &block)
    rules << CanCan::CustomRule.new(true, action, subject, conditions, block)
  end

  def cannot(action = nil, subject = nil, conditions = nil, &block)
    rules << CanCan::CustomRule.new(false, action, subject, conditions, block)
  end

end
