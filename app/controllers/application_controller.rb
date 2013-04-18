# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :current_user_name, :current_user, :current_user_full_name, :current_session, :logged_in?

  include ChecksAuthentication
  before_filter :check_authentication
  before_filter :set_locale
  before_filter :update_activity_time

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
  
  def render_error_response(ex)
    @exception = ex

    # Only add the error page to the status code if the request-format was HTML
    respond_to do |format|
      format.html do
        render(
          :template => "shared/status_#{ex.status_code.to_s}",
          :status => ex.status_code
        )
      end
      format.any(:xml,:json) do
        begin
        render(
          :template => "shared/status_#{ex.status_code.to_s}",
          :status => ex.status_code
        )
        rescue ActionView::MissingTemplate
          head ex.status_code # only return the status code
        end
      end
    end
  end

  # TODO Remove duplication in ApplicationHelper
  def current_user_name
    current_user.try(:user_name)
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def current_user_full_name
    current_user.try(:full_name)
  end

  def current_user
    @current_user ||= current_session.try(:user)
  end

  def current_session
    @current_session ||= get_session
  end

  def logged_in?
    !current_session.nil? unless request.nil?
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

  def session_expiry
    session = current_session
    unless session.nil?
      if session.expired?
        flash[:error] = t('session.has_expired')
        redirect_to logout_path
      end
    end
  end

  def update_activity_time
    session = current_session
    unless session.nil? || ((session.expires_at || Time.now) > 19.minutes.from_now)
      session.update_expiration_time(20.minutes.from_now)
      session.save
      session.put_in_cookie cookies
    end
  end

  def set_locale
    if logged_in?
      I18n.locale = (current_user.locale || I18n.default_locale)
      if I18n.locale != I18n.default_locale
        I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
        begin
          I18n.fallbacks.map(I18n.locale => I18n.default_locale)
        rescue I18n::MissingTranslationData
          I18n.fallbacks.map(I18n.locale => :en)
        end
      end
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
