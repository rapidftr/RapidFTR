# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_name, :current_user, :current_user_full_name, :current_session, :logged_in?

  include Security::Authentication

  before_action :check_authentication
  before_action :extend_session_lifetime
  before_action :set_locale

  rescue_from(Exception, ActiveSupport::JSON.parse_error) do |e|
    fail e if Rails.env.development?
    ErrorResponse.log e
    render_error_response ErrorResponse.internal_server_error "session.internal_server_error"
  end
  rescue_from CanCan::AccessDenied do |e|
    ErrorResponse.log e
    render_error_response ErrorResponse.forbidden "session.forbidden"
  end
  rescue_from(ErrorResponse) do |e|
    ErrorResponse.log e
    render_error_response e
  end

  def extend_session_lifetime
    session[:last_access_time] = Clock.now.rfc2822
  end

  def render_error_response(e)
    respond_to do |format|
      format.json do
        render :status => e.status_code, :text => e.message
      end
      format.any do
        if e.status_code == 401
          redirect_to :login
        else
          render :formats => [:html], :template => "shared/error_response", :status => e.status_code, :locals => {:exception => e}
        end
      end
    end
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
    param.reject { |value| value.blank? }
  end

  def encrypt_exported_files(results, zip_filename)
    return unless params[:password].present?
    enc_filename = CleansingTmpDir.temp_file_name

    ZipRuby::Archive.open(enc_filename, ZipRuby::CREATE) do |ar|
      results.each do |result|
        ar.add_or_replace_buffer File.basename(result.filename), result.data
      end
      ar.encrypt params[:password]
    end

    send_file enc_filename, :filename => zip_filename, :disposition => "inline", :type => 'application/zip'
  end

  ActionView::Base.field_error_proc = proc do |html_tag, _instance|
    %(<span class="field-error">) + html_tag + %(</span>)
  end
end
