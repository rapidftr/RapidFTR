class AdminController < ApplicationController

  before_filter {
    authorize!(false, false) if cannot?(:manage, ContactInformation) and cannot?(:highlight, Field)
  }

  def index
    @page_name = t("administration")
  end

end
