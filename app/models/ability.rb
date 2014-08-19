class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    alias_action :index, :view, :list, :to => :read
    alias_action :edit, :to => :update

    @user = user

    #
    # CHILDREN
    #
    initialize_child_permissions(user)

    #
    # ENQUIRIES
    #
    initialize_enquiry_permissions(user)

    #
    # USERS
    #

    # Can edit and see own details
    initialize_user_permissions(user)

    #
    # DEVICES
    #
    initialize_device_permissions(user)

    #
    # ROLES
    #
    initialize_role_permissions(user)

    #
    # FORMS
    #

    initialize_form_permissions(user)

    #
    # REPLICATIONS
    #
    initialize_replication_permissions(user)

    #
    # SYSTEM SETTINGS
    #
    # SYNCHRONISATION USERS
    initialize_system_settings_permissions(user)
  end

  def initialize_system_settings_permissions(user)
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

  def initialize_replication_permissions(user)
    if user.has_permission?(Permission::DEVICES[:replications])
      can [:manage], Replication
    end
  end

  def initialize_form_permissions(user)
    if user.has_permission?(Permission::FORMS[:manage])
      can [:manage], FormSection
      can [:manage], Field, :except => :highlight
    end
  end

  def initialize_role_permissions(user)
    if user.has_permission?(Permission::ROLES[:view])
      can [:read], Role
    end

    if user.has_permission?(Permission::ROLES[:create_and_edit])
      can [:manage], Role
    end
  end

  def initialize_device_permissions(user)
    if user.has_permission?(Permission::DEVICES[:black_list])
      can [:read, :update], Device
    end

    if user.has_permission?(Permission::DEVICES[:replications])
      can [:manage], Replication
    end
  end

  def initialize_user_permissions(user)
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
  end

  def initialize_enquiry_permissions(user)
    if user.has_permission?(Permission::ENQUIRIES[:create])
      can [:create], Enquiry do |enquiry|
        enquiry.created_by == user.user_name
      end
    end

    if user.has_permission?(Permission::ENQUIRIES[:update])
      can [:update, :read], Enquiry
    end

    if user.has_permission?(Permission::ENQUIRIES[:view])
      can [:read, :view_all], Enquiry
    end
  end

  def initialize_child_permissions(user)
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
  end

  def can(action = nil, subject = nil, conditions = nil, &block)
    rules << CanCan::CustomRule.new(true, action, subject, conditions, block)
  end

  def cannot(action = nil, subject = nil, conditions = nil, &block)
    rules << CanCan::CustomRule.new(false, action, subject, conditions, block)
  end
end
