class ReplicationsController < ApplicationController

  before_filter :load_replication

  skip_before_filter :verify_authenticity_token
  skip_before_filter :check_authentication, :only => :config

  def config
    render :json => COUCHDB_CONFIG
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

end
