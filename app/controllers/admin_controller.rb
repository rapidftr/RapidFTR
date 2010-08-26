class AdminController < ApplicationController

  before_filter :administrators_only

  def index
    @page_name = "Administration"
  end
end