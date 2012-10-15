class RolesController < ApplicationController

  before_filter :authorize

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def create
    params[:role][:permissions].reject!{|permission| permission.blank? }
    @role = Role.new(params[:role])
    return redirect_to roles_path if @role.save
    render :new
  end

  private
  def authorize
    authorize! :manage, Role
  end

end
