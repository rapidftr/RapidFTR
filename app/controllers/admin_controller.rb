class AdminController < ApplicationController

  before_filter :check_authorization

  def index
    @page_name = "Administration"
  end
end