class EnquiriesController < ApplicationController
  before_action :load_enquiry, :only => [:show, :edit, :update]

  def index
    authorize! :index, Enquiry

    @page_name = t('home.view_records')
    @filter = params[:filter] || nil
    @order = params[:order_by] || EnquiriesHelper::ORDER_BY[@filter] || 'created_at'
    @sort_order = (params[:sort_order].nil? || params[:sort_order].empty?) ? :asc : params[:sort_order]
    per_page = params[:per_page] || EnquiriesHelper::View::PER_PAGE
    per_page = per_page.to_i unless per_page == 'all'
    page = params[:page] || 1

    search = EnquirySearch.new.
        paginated(page, per_page).
        ordered(@order, @sort_order.to_sym).
        marked_as(@filter)

    @enquiries = search.results

    respond_to do |format|
      format.html
      format.xml { render :xml => @enquiries }
      unless params[:format].nil?
        if @enquiries.empty?
          flash[:notice] = t('enquiry.no_records_available')
          redirect_to(:action => :index) && return
        end
      end
    end
  end

  def new
    @enquiry = Enquiry.new
    @form_sections = enquiry_form_sections
  end

  def create
    authorize! :create, Enquiry
    @enquiry = Enquiry.new_with_user_name current_user, params[:enquiry]

    if @enquiry.save
      flash[:notice] = t('enquiry.messages.creation_success')
      redirect_to(@enquiry)
    else
      @form_sections = enquiry_form_sections
      render :new
    end
  end

  def edit
    authorize! :update, Enquiry
    @form_sections = enquiry_form_sections
  end

  def update
    authorize! :update, Enquiry

    if !params[:match_id].nil?
      @enquiry[:potential_matches].delete params[:match_id]
      @enquiry.id_marked_as_not_matching = params[:match_id]
      @enquiry.save
      redirect_to :action => :show, :anchor => 'tab_potential_matches'
      return
    end

    if @enquiry.update_attributes(params[:enquiry])
      flash[:notice] = t('enquiry.messages.update_success')
      redirect_to enquiry_path(@enquiry)
    else
      @form_sections = enquiry_form_sections
      render :edit
    end
  end

  def show
    authorize! :read, Enquiry
    @form_sections = enquiry_form_sections
    @potential_matches = potential_matches

    respond_to do |format|
      format.html
      format.xml { render :xml => @enquiry }
      format.json { render :json => @enquiry }
    end
  end

  def matches
    @filter = params[:filter] || nil
    @order = params[:order_by] || EnquiriesHelper::ORDER_BY[@filter] || 'created_at'
    @sort_order = (params[:sort_order].nil? || params[:sort_order].empty?) ? :asc : params[:sort_order]
    per_page = params[:per_page] || EnquiriesHelper::View::PER_PAGE
    page = params[:page] || 1

    @enquiries = Enquiry.with_child_potential_matches(:per_page => per_page, :page => page)

    respond_to do |format|
      format.html { render :template => 'enquiries/index_with_potential_matches' }
      format.xml { render :xml => @enquiries }
    end
  end

  private

  def load_enquiry
    @enquiry = Enquiry.find params[:id]
  end

  def enquiry_form_sections
    FormSection.enabled_by_order_for_form(Enquiry::FORM_NAME)
  end

  def potential_matches
    matches = []
    @enquiry.potential_matches.each { |id| matches << Child.get(id) }
    matches
  end
end
