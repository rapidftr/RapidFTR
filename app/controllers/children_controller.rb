class ChildrenController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :load_child_or_redirect, :only => [:show, :edit, :destroy, :edit_photo, :update_photo, :export_photo_to_pdf]
  before_filter :current_user

  # GET /children
  # GET /children.xml
  def index
    @page_name = "View All Children"
    @children = Child.all
    @aside = 'shared/sidebar_links'

    respond_to do |format|
      format.html { @highlighted_fields = FormSection.sorted_highlighted_fields }
      format.xml  { render :xml => @children }
      format.csv  { render_as_csv @children, "all_records_#{file_name_date_string}.csv" }
      format.json { render :json => @children }
      format.pdf do
        pdf_data = ExportGenerator.new(@children).to_full_pdf
        send_pdf(pdf_data, "#{file_basename}.pdf")
      end
    end
  end

  # GET /children/1
  # GET /children/1.xml
  def show
    @form_sections = get_form_sections

    @page_name = "View Child: #{@child}"

    @aside = 'picture'
    @body_class = 'profile-page'

    respond_to do |format|
      format.html
      format.xml  { render :xml => @child }
      format.json { render :json => @child.to_json }
      format.csv do
        child_ids = [@child]
        render_as_csv(child_ids, current_user_name+"_#{file_name_datetime_string}.csv")
      end
      format.pdf do
        pdf_data = ExportGenerator.new(@child).to_full_pdf
        send_pdf( pdf_data, "#{file_basename(@child)}.pdf" )
      end
    end
  end

  # GET /children/new
  # GET /children/new.xml
  def new
    @page_name = "Register New Child"
    @child = Child.new
    @form_sections = get_form_sections
    respond_to do |format|
      format.html
      format.xml  { render :xml => @child }
    end
  end

  # GET /children/1/edit
  def edit
    @page_name = "Edit Child"
    @form_sections = get_form_sections
  end

  # POST /children
  # POST /children.xml
  def create
    @child = Child.new_with_user_name(current_user_name, params[:child])
    respond_to do |format|
      if @child.save
        flash[:notice] = 'Child record successfully created.'
        format.html { redirect_to(@child) }
        format.xml  { render :xml => @child, :status => :created, :location => @child }
        format.json { render :json => @child.to_json }
      else
        format.html {
          @form_sections = get_form_sections
          render :action => "new"
        }
        format.xml  { render :xml => @child.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit_photo
    @page_name = "Edit Photo"
  end

  def update_photo
    orientation = params[:child].delete(:photo_orientation).to_i
    if orientation != 0
      @child.rotate_photo(orientation)
      @child.set_updated_fields_for current_user_name
      @child.save
    end
    redirect_to(@child)
  end


  def new_search

  end

  # PUT /children/1
  # PUT /children/1.xml
  def update
    @child = Child.get(params[:id]) || Child.new_with_user_name(current_user_name, params[:child])
    new_photo = params[:child].delete(:photo)
    new_audio = params[:child].delete(:audio)
    @child.update_properties_with_user_name(current_user_name, new_photo, params[:delete_child_photo], new_audio, params[:child])

    respond_to do |format|
      if @child.save
        flash[:notice] = 'Child was successfully updated.'
        format.html { redirect_to(@child) }
        format.xml  { head :ok }
        format.json { render :json => @child.to_json }
      else
        format.html {
          @form_sections = get_form_sections
          render :action => "edit"
        }
        format.xml  { render :xml => @child.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /children/1
  # DELETE /children/1.xml
  def destroy
    @child.destroy

    respond_to do |format|
      format.html { redirect_to(children_url) }
      format.xml  { head :ok }
      format.json { render :json => {:response => "ok"}.to_json }
    end
  end

  def search
    @page_name = "Search"
    @aside = "shared/sidebar_links"
    if (params[:query])
      @search = Search.new(params[:query]) 
      if @search.valid?    
        @results = Child.search(@search)
        @highlighted_fields = FormSection.sorted_highlighted_fields
      else
        render :search
      end
    end
    default_search_respond_to
  end

  def export_data
    selected_records = params["selections"] || {}
    if selected_records.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported')
    end
    
    children = selected_records.sort.map{ |index, child_id| Child.get(child_id) }

    if params[:commit] == "Export to Photo Wall"
      export_photos_to_pdf(children, "#{file_basename}.pdf")
    elsif params[:commit] == "Export to PDF"
			pdf_data = ExportGenerator.new(children).to_full_pdf
			send_pdf(pdf_data, "#{file_basename}.pdf")
    elsif params[:commit] == "Export to CSV"
      render_as_csv(children, "#{file_basename}.csv")
    end
  end

  def export_photos_to_pdf children, filename
    pdf_data = ExportGenerator.new(children).to_photowall_pdf
    send_pdf( pdf_data, filename)
  end

  def export_photo_to_pdf
    pdf_data = ExportGenerator.new(@child).to_photowall_pdf
    send_pdf(pdf_data, "#{file_basename(@child)}.pdf")
  end


  private

	def file_basename(child = nil)
		prefix = child.nil? ? current_user_name : child.unique_identifier
    user = User.find_by_user_name(current_user_name)
		"#{prefix}-#{Clock.now.in_time_zone(user.time_zone).strftime('%Y%m%d-%H%M')}"
  end

  def file_name_datetime_string
    user = User.find_by_user_name(current_user_name)
    Clock.now.in_time_zone(user.time_zone).strftime('%Y%m%d-%H%M')
  end

  def file_name_date_string
    user = User.find_by_user_name(current_user_name)
    Clock.now.in_time_zone(user.time_zone).strftime("%Y%m%d")
  end

  def get_form_sections
    FormSection.enabled_by_order
  end

  def default_search_respond_to
    respond_to do |format|
     format.html do
       if @results && @results.length == 1
         redirect_to child_path( @results.first )
       end
     end
      format.csv do
        render_as_csv(@results, 'rapidftr_search_results.csv') if @results
      end
    end
  end

  def render_as_csv results, filename
    results = results || [] # previous version handled nils - needed? 
		export_generator = ExportGenerator.new results
		csv_data = export_generator.to_csv 'http://' + request.domain + ":" + request.port.to_s
    send_data(csv_data.data, csv_data.options)
  end

  def load_child_or_redirect
    @child = Child.get(params[:id])

    return unless request.format.html?

    if @child.nil?
      flash[:error] = "Child with the given id is not found"
      redirect_to :action => :index and return
    end
  end

end
