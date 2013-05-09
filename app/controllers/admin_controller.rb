class AdminController < ApplicationController

  before_filter {
    authorize!(false, false) if cannot?(:manage, ContactInformation) and cannot?(:highlight, Field) and cannot?(:manage, SystemUsers)
  }

  def index
    @page_name = t("administration")
  end

  def update
    I18n.default_locale = params[:locale]
    I18n.locale=I18n.default_locale
    flash[:notice] = I18n.translate("user.messages.time_zone_updated")
    redirect_to admin_path
  end

end
