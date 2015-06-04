class AdminController < ApplicationController
  before_action do
    authorize!(false, false) if cannot?(:highlight, Field) && cannot?(:manage, SystemUsers)
  end

  before_action :validate_size_of, :only => [:logo]
  before_action :validate_png, :only => [:logo]

  def index
    @page_name = t('administration')
  end

  def update
    I18n.default_locale = params[:locale]
    I18n.locale = I18n.default_locale
    flash[:notice] = I18n.translate('user.messages.time_zone_updated')
    redirect_to admin_path
  end

  def logo
    path =  Rails.root.join(File.join('public', '/logo.png'))
    File.open(path, 'wb') { |file| file.write(params[:logo].read) }
    redirect_to admin_path
  end

  private

  def validate_size_of
    if params[:logo].size > 1.megabyte
      flash[:error] = I18n.translate('messages.file_size_exceeds_limitation_of_1mb')
      redirect_to admin_path
    end
  end

  def validate_png
    unless params[:logo].content_type == 'image/png'
      flash[:error] = I18n.translate('messages.expecting_png')
      redirect_to admin_path
    end
  end
end
