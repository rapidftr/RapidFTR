class SessionsController < ApplicationController

  skip_before_filter :check_authentication, :only => %w{new create active}

  # GET /sessions/1
  # GET /sessions/1.xml
  def show
    #logger.debug( cookies.inspect )
    logger.debug("Authorization header: #{request.headers['Authorization']}")
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
    I18n.locale = I18n.default_locale
    unless (@session = current_session).nil?
      return redirect_to(:action => "show", :id => @session)
    end

    @session = Session.new(params[:login])

    @page_name = t("login.label")

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @session }
    end
  end

  # POST /sessions
  # POST /sessions.xml
  def create
    @login = Login.new(params)
    @session, failed_attempts = @login.authenticate_user

    if not @session
      respond_to do |format|
        if (failed_attempts==3)
          handle_login_error("You are locked. Try one minute later.", format)
        else
          handle_login_error(failed_attempts, format)
        end
      end
      return
    end

    if @session.device_blacklisted?
      handle_device_blacklisted(@session)
      return
    end

    respond_to do |format|
      if @session.save
        reset_session
        session[:rftr_session_id] = @session.id
        flash[:notice] = t("hello") + " " + @session.user_name
        format.html { redirect_to(root_path) }
        format.xml { render :action => "show", :status => :created, :location => @session }
        format.json { render_session_as_json(@session, :status => :created, :location => @session) }
      else
        handle_login_error(t("session.login_error"), format)
      end
    end
  end

  # PUT /sessions/1
  # PUT /sessions/1.xml


  # DELETE /sessions/1
  # DELETE /sessions/1.xml
  def destroy
    @session = current_session
    @session.destroy if @session
    reset_session

    respond_to do |format|
      format.html { redirect_to(:login) }
      format.xml { head :ok }
    end
  end

  def active
    render :text => 'OK'
  end

  private
  def handle_login_error(notice, format)
    format.html {
      flash[:error] = notice
      redirect_to :action => "new" }
    format.xml { render :xml => errors, :status => :unprocessable_entity }
    format.json { head :unauthorized }
  end

  def render_session_as_json(session, options = {})
    user = User.find_by_user_name(session.user_name)
    json = {
      :session => {
        :token => session.token,
        :link => {
          :rel => 'session',
          :uri => session_path(session)
        }
      },
      :db_key => MobileDbKey.find_or_create_by_imei(session.imei).db_key,
      :organisation => user.organisation,
      :language => I18n.default_locale,
      :verified => user.verified?
    }
    render(options.merge(:json => json))
  end

end
