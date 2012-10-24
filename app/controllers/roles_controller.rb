class RolesController < ApplicationController

  before_filter :authorize

  def index
    @roles = params[:sort] == "desc" ? Role.by_name.reverse : Role.by_name
  end

  def edit
    @role = Role.get(params[:id])
  end

  def update
    @role = Role.get(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = "Role details are successfully updated."
    else
      flash[:error] = "Error in updating the Role details."
    end
    render :nothing => true
  end

  def new
    @role = Role.new
  end

  def create
    params[:role][:permissions].reject! { |permission| permission.blank? }
    @role = Role.new(params[:role])
    return redirect_to roles_path if @role.save
    render :new
  end

  private
  def authorize
    authorize! :manage, Role
  end

end
