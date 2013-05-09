# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_name, :current_user, :current_user_full_name, :current_session, :logged_in?

  include Security::Authentication

  before_filter :extend_session_lifetime
  before_filter :check_authentication
  before_filter :set_locale

  rescue_from( AuthenticationFailure ) { |e| handle_authentication_failure(e) }
  rescue_from( AuthorizationFailure ) { |e| handle_authorization_failure(e) }
  rescue_from( ErrorResponse ) { |e| render_error_response(e) }
  rescue_from CanCan::AccessDenied do |exception|
    if request.format == "application/json"
      render :json => "unauthorized", :status => 403
    else
      render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    end
  end

  def extend_session_lifetime
    request.env[ActionDispatch::Session::AbstractStore::ENV_SESSION_OPTIONS_KEY][:expire_after] = 1.week if request.format.json?
  end

  def handle_authentication_failure(auth_failure)
    respond_to do |format|
      format.html { redirect_to(:login) }
      format.any(:xml,:json) { render_error_response ErrorResponse.unauthorized(I18n.t("session.invalid_token")) }
    end
  end

  def handle_authorization_failure(authorization_failure)
    respond_to do |format|
      format.any { render_error_response ErrorResponse.new(403, authorization_failure.message) }
    end
  end

  def handle_device_blacklisted(session)
    render(:status => 403, :json => session.imei)
  end

  def render_error_response(ex)
    respond_to do |format|
      format.html do
        render :template => "shared/error_response",:status => ex.status_code, :locals => { :exception => ex }
      end
      format.any(:xml,:json) do
        render :text => nil, :status => ex.status_code
      end
    end
  end

  def send_pdf(data, filename)
    send_encrypted_file data, :filename => filename, :type => "application/pdf"
  end

  def send_csv(csv, opts = {})
    send_encrypted_file csv, opts
  end

  def name
    self.class.to_s.gsub("Controller", "")
  end

  def set_locale
    if logged_in?
      I18n.locale = (current_user.locale || I18n.default_locale)
      RapidFTR::Translations.set_fallbacks
    end
  end

  def clean_params(param)
    param.reject{|value| value.blank?}
  end

  def send_encrypted_file(data, opts = {})
    if params[:password].present?
      zip_filename = File.basename(opts[:filename], ".*") + ".zip"
      enc_filename = "#{generate_encrypted_filename}.zip"

      Zip::Archive.open(enc_filename, Zip::CREATE) do |ar|
        ar.add_or_replace_buffer opts[:filename], data
        ar.encrypt params[:password]
      end

      send_file enc_filename, :filename => zip_filename, :disposition => "inline", :type => 'application/zip'
    end
  end

  def generate_encrypted_filename
    dir = CleanupEncryptedFiles.dir_name
    FileUtils.mkdir_p dir
    File.join dir, UUIDTools::UUID.random_create.to_s
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    %(<span class="field-error">) + html_tag + %(</span>)
  end

end
