class ReplicationsController < ApplicationController

  before_filter :load_replication
  before_filter :authenticate_couch_internal_user, :only => [:configuration]

  skip_before_filter :verify_authenticity_token, :only => [ :configuration, :start, :stop ]

  def configuration
    #send the target url with the credentials given by user.
    render :json => Replication.configuration
  end

  def index
    authorize! :read, Replication
    @replications = Replication.all
  end

  def new
    authorize! :create, Replication
    @replication = Replication.new
  end

  def create
    authorize! :create, Replication
    @replication = Replication.new params[:replication]

    if @replication.save
      redirect_to :action => :index
    else
      render :new
    end
  end

  def edit
    authorize! :edit, @replication
  end

  def update
    authorize! :update, @replication
    @replication.update_attributes params[:replication]

    if @replication.save
      @replication.restart_replication
      redirect_to :action => :index
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @replication
    @replication.destroy
    redirect_to :action => :index
  end

  def start
    authorize! :start, @replication
    @replication.restart_replication
    redirect_to :action => :index
  end

  def stop
    authorize! :stop, @replication
    @replication.stop_replication
    redirect_to :action => :index
  end

  private

  def load_replication
    @replication = Replication.get params[:id] if params[:id]
  end

  def authenticate_couch_internal_user
    Replication.authenticate_with_internal_couch_users(params[:user_name], params[:password])
  end
end
