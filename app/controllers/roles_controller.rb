class RolesController < ApplicationController

  def index
    authorize! :index, Role
    @page_name = t("roles.label")
    sort_option = params[:sort_by_descending_order] || false
    params[:show] ||= "All"
    @roles = params[:show] == "All" ? Role.by_name(:descending => sort_option) : Role.by_name(:descending => sort_option).find_all { |role| role.has_permission(params[:show]) }
  end

  def show
    @role = Role.get(params[:id])
    authorize! :view, @role
  end

  def edit
    @role = Role.get(params[:id])
    authorize! :update, @role
  end

  def update
    @role = Role.get(params[:id])
    authorize! :update, @role

    if @role.update_attributes(params[:role])
      flash[:notice] = t("role.successfully_updated")
      redirect_to(roles_path)
    else
      flash[:error] = t("role.error_in_updating")
      render :action => "edit"
    end
  end

  def new
    authorize! :create, Role
    @role = Role.new
  end

  def create
    authorize! :create, Role
    @role = Role.new(params[:role])
    return redirect_to roles_path if @role.save
    render :new
  end
end
