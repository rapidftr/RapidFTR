class EnquiriesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :check_authentication, :only => [:reindex]

  before_filter :load_enquiry_or_redirect, :only => [:show, :edit, :destroy]
  before_filter :current_user, :except => [:reindex]

  # GET /enquiries
  def index
    # Skeleton based on child controller code
    authorize! :index, Enquiry

    @page_name = t("home.view_enquiries")
    @aside = 'shared/sidebar_links'
    @filter = params[:filter] || params[:status] || "all"
    @order = params[:order_by] || 'enquirer_name'
    setup_fields!
    per_page = params[:per_page] || EnquiriesHelper::View::PER_PAGE
    per_page = per_page.to_i unless per_page == 'all'

    filter_enquiries per_page
  end

  # GET /enquiries/1
  def show
    authorize! :show, @enquiry

    @page_name = t("enquiry.view")
    @body_class = 'profile-page'
    @enquiry = Enquiry.get(params[:id])
    setup_fields!
  end

  # GET /enquiries/new
  def new
    # Skeleton based on child controller code
    authorize! :create, Enquiry

    @page_name = t("enquiries.create_new_enquiry")
    setup_fields!
    @exclude_tabs = ["e98c765c"]
    @enquiry = Enquiry.new 
  end

  # GET /enquiries/1/edit
  def edit
    # Skeleton based on child controller code
    authorize! :update, @enquiry

    @page_name = t("enquiry.edit")
    setup_fields!
  end

  # POST /enquiries
  def create
    # Skeleton based on child controller code
    authorize! :create, Enquiry

    params[:enquiry] = params[:child]
    params[:enquiry][:criteria] = params[:child]
    create_or_update_enquiry(params[:enquiry])
    @enquiry['created_by_full_name'] = current_user_full_name    
    respond_to do |format|    
      if @enquiry.save!
          format.html { redirect_to(@enquiry) }
          format.xml { render :xml => @enquiry, :status => :created, :location => @enquiry }
          format.json {
            render :json => @enquiry.compact.to_json
          }
      else
          format.html {
            @form_sections = get_form_sections
            render :action => "new"
          }
          format.xml { render :xml => @enquiry.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    # Not yet implemented
  end

  private

  def load_enquiry_or_redirect
    @enquiry = Enquiry.get(params[:id])

    if @enquiry.nil?
      flash[:error] = "Enquiry with the given id is not found"
      redirect_to :action => :index and return
    end
  end

  def filter_enquiries(per_page)
    total_rows, enquiries = enquiries_by_user_access(@filter, per_page)
    @enquiries = paginated_collection enquiries, total_rows
  end

  def enquiries_by_user_access(filter_option, per_page)
    # Skeleton based on child controller code
    keys = [filter_option] # Not currently using keys
    options = {}
    all_rows = Enquiry.view("all")
    return all_rows.length, all_rows
  end

  def paginated_collection instances, total_rows
    page = params[:page] || 1
    WillPaginate::Collection.create(page, EnquiriesHelper::View::PER_PAGE, total_rows) do |pager|
      pager.replace(instances)
    end
  end

  def setup_fields!
    @form_sections = get_form_sections
    @fields = @form_sections.collect{ |section| section["fields"] }.flatten
    @exclude_tabs = []
  end

  def get_form_sections
    JSON.parse(File.read(Rails.root.join("config", "enquiry_form_sections.json").to_s)).collect do |form_section|
      form_section["fields"].each do |field|
        field["display_name"].each do |lang, str|
          field["display_name_#{lang}"] = str
        end
        field.delete("display_name")

        if field.has_key? "option_strings_text"
          field["option_strings_text"].each do |lang, arr|
            field["option_strings_text_#{lang}"] = arr.join("\n")
          end
          field.delete("option_strings_text")
        end

        Field.new(field)
      end

      ["name", "help_text", "description"].each do |property|
        form_section[property].each do |lang, str|
          form_section["#{property}_#{lang}"] = str
        end
        form_section.delete(property)
      end

      FormSection.new(form_section)
    end
  end

  def create_or_update_enquiry(enquiry_params)
    if @enquiry.nil?
      @enquiry = Enquiry.new_with_user_name(current_user, enquiry_params)
    else
      @enquiry = update_from(params)
    end    
  end

end
