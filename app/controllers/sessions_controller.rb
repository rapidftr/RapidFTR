class SessionsController < ApplicationController

  include LoadsSession

  skip_before_filter :check_authentication, :only => %w{new create active}

  protect_from_forgery :except => %w{create}

  # GET /sessions/1
  # GET /sessions/1.xml
  def show
    #logger.debug( cookies.inspect )
    logger.debug( "Authorization header: #{request.headers['Authorization']}" )
    @session = Session.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml
      format.json do
        render_session_as_json(@session)
      end
    end
  end

  # GET /sessions/new
  # GET /sessions/new.xml
  def new
    unless (@session = get_session).nil?
      return redirect_to(:action => "show", :id => @session)
    end

    @session = Session.new(params[:login])

    @page_name = "Login"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @session }
    end
  end

  # POST /sessions
  # POST /sessions.xml
  def create
    if user_is_logged_in?(params[:user_name])
      respond_to do |format|
        handle_login_error("This user is already logged in.", format)
      end
      return
    end

    @login = Login.new(params)
    @session = @login.authenticate_user
    
    if not @session
      respond_to do |format|
        handle_login_error("Invalid credentials. Please try again!", format)
      end

      return
    end
    
    if @session.device_blacklisted?
      handle_device_blacklisted(@session) 
      return
    end
    
    respond_to do |format|
      if @session.save
        @session.put_in_cookie(cookies)
        flash[:notice] = 'Hello ' + @session.user_name
        format.html { redirect_to(root_path) }
        format.xml  { render :action => "show", :status => :created, :location => @session }
        format.json { render_session_as_json(@session, :status => :created, :location => @session) }
      else
        handle_login_error("There was a problem logging in.  Please try again.", format)
      end
    end
  end

  # PUT /sessions/1
  # PUT /sessions/1.xml


  # DELETE /sessions/1
  # DELETE /sessions/1.xml
  def destroy
    @session = get_session
    user = User.find_by_user_name(@session.user_name)
    @session.destroy if @session
    Session.remove_from_cookies(cookies)

    respond_to do |format|
      format.html { redirect_to(:login) }
      format.xml  { head :ok }
    end
  end

  def active
    render :text => 'OK'
  end

  private

  def user_is_logged_in? user_name
    !(Session.find_by_user_name(user_name).blank?)
  end

  def handle_login_error(notice, format)
    format.html {
      flash[:error] = notice
      redirect_to :action => "new" }
    format.xml  { render :xml => errors, :status => :unprocessable_entity }
    format.json { head :unauthorized }
  end

  def render_session_as_json(session, options = {})
    json = {
            :session => {
                    :token => session.token,
                    :link => {
                            :rel => 'session',
                            :uri => session_path(session)
                    }
            }
    }
    render( options.merge( :json => json ) )
  end

end
