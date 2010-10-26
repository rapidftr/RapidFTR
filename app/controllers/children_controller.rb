class   ChildrenController < ApplicationController

  skip_before_filter :verify_authenticity_token

  # GET /children
  # GET /children.xml
  def index
    @page_name = "Listing children"
    @children = Child.all
    @aside = 'search_sidebar'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @children }
      format.json { render :json => @children }
    end
  end

  # GET /children/1
  # GET /children/1.xml
  def show
    @child = Child.get(params[:id])

    @form_sections = get_form_sections

    @page_name = @child

    @aside = 'picture'
    @body_class = 'profile-page'

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @child }
      format.json { render :json => @child.to_json }
      format.pdf do
        pdf_data = PdfGenerator.new.child_photo(@child)
        send_pdf( pdf_data, "#{@child.unique_identifier}-#{Clock.now.strftime('%Y%m%d-%H%M')}.pdf" )
      end
    end
  end

  # GET /children/new
  # GET /children/new.xml
  def new
    @page_name = "New child record"
    @child = Child.new
    @form_sections = get_form_sections
    respond_to do |format|
      format.html
      format.xml  { render :xml => @child }
    end
  end

  # GET /children/1/edit
  def edit
    @page_name = "Edit child record"
    @child = Child.get(params[:id])
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

  # PUT /children/1
  # PUT /children/1.xml
  def update
    @child = Child.get(params[:id])
    new_photo = params[:child].delete(:photo)
    new_audio = params[:child].delete(:audio)
    @child.update_properties_with_user_name(current_user_name, new_photo, new_audio, params[:child])


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
    @child = Child.get(params[:id])
    @child.destroy

    respond_to do |format|
      format.html { redirect_to(children_url) }
      format.xml  { head :ok }
      format.json { render :json => {:response => "ok"}.to_json }
    end
  end

  def search
    @page_name = "Child Search"
    search = Search.new(params[:query]) 
    if search.valid?    
      @results = Child.search(search)
    else
      @search = search
      render :search
    end
    default_search_respond_to
  end

  def advanced_search
    @page_name = "Advanced Child Search"
    @fields_name = FormSection.all_child_field_names
    
    search = AdvancedSearch.new(params[:search_field], params[:search_value])    
    if (search.valid?)
      @results = Summary.advanced_search(params[:search_field], params[:search_value]) if params[:search_value]
      default_search_respond_to
    else
      @search = search
      render :advanced_search
    end
  end

  def default_search_respond_to
    respond_to do |format|
     format.html do
       @show_thumbnails = !!params[:show_thumbnails]
       if @results && @results.length == 1
         redirect_to child_path( @results.first )
       end
     end
      format.csv do
        render_results_as_csv if @results
      end
    end
  end

  def photo_pdf
    child_ids = params.map{ |k, v| 'selected' == v ? k : nil }.compact
    if child_ids.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported')
    end
    children = child_ids.map{ |child_id| Child.get(child_id) }
    pdf_data = PdfGenerator.new.child_photos(children)
    send_pdf( pdf_data, "#{current_user_name}-#{Clock.now.strftime('%Y%m%d-%H%M')}.pdf" )
  end

  private

  def get_form_sections
    FormSection.all_by_order
  end

  def render_results_as_csv
    field_names = FormSection.all_child_field_names
    csv = FasterCSV.generate do |rows|
      rows << field_names
      @results.each do |child|
        rows << field_names.map{ |field_name| child[field_name] }
      end
    end

    send_data( csv, :filename => 'rapidftr_search_results.csv', :type => 'text/csv' )
  end
end
