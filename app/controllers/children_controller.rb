class ChildrenController < ApplicationController

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

    @form_sections = get_form_sections_for_child @child

    @page_name = @child["name"]

    @aside = 'picture'
    @body_class = 'profile-page'

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @child }
      format.custom("image/jpeg") { send_data(@child.photo, :type => "image/jpeg")}
      format.json { render :json => @child.to_json }
      format.pdf do
        pdf_data = PdfGenerator.new.child_photo(@child)
        send_pdf( pdf_data, "photo.pdf" )
      end
    end
  end

  # GET /children/new
  # GET /children/new.xml
  def new
    uses_javascript 'children/form.js'
    @page_name = "New child record"
    @child = Child.new
    @form_sections = get_form_sections_for_child @child
    respond_to do |format|
      format.html
      format.xml  { render :xml => @child }
    end
  end

  # GET /children/1/edit
  def edit
    uses_javascript 'children/form.js'
    @page_name = "Edit child record"
    @child = Child.get(params[:id])
    @form_sections = get_form_sections_for_child @child
  end

  # POST /children
  # POST /children.xml
  def create
    @child = Child.new_with_user_name(current_user_name, params[:child])
    @child['relations'] = extract_relations_from_params(params)

    respond_to do |format|
      if @child.save
        flash[:notice] = 'Child record successfully created.'
        format.html { redirect_to(@child) }
        format.xml  { render :xml => @child, :status => :created, :location => @child }
        format.json { render :json => @child.to_json }
      else
        format.html {
          @form_sections = get_form_sections_for_child @child
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
    @child.update_properties_with_user_name current_user_name, new_photo, params[:child]
    @child['relations'] = extract_relations_from_params(params)

    respond_to do |format|
      if @child.save
        flash[:notice] = 'Child was successfully updated.'
        format.html { redirect_to(@child) }
        format.xml  { head :ok }
        format.json { render :json => @child.to_json }
      else
        format.html {
          @form_sections = get_form_sections_for_child @child
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
    @results = Summary.basic_search(params[:child_name], params[:unique_identifier])

    respond_to do |format|
      format.csv do
        render_results_as_csv
      end
      format.html do
        @show_thumbnails = !!params[:show_thumbnails]
        @show_csv_export_link = !@results.empty?

        if 1 == @results.length
          redirect_to child_path( @results.first )
        end
      end
    end
  end

  def photo_pdf
    child_ids = params.map{ |k,v| 'selected' == v ? k : nil }.compact
    if child_ids.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported') 
    end
    children = child_ids.map{ |child_id| Child.get(child_id) }
    pdf_data = PdfGenerator.new.child_photos(children)
    send_pdf( pdf_data, "photos.pdf" )
  end

  private

  def get_form_sections_for_child child
  forms = []
    Templates.child_form_section_names.each do |section_name|
      forms << FormSection.create_form_section_from_template(section_name, Templates.get_template(section_name), child)
    end
    return forms
  end

  def render_results_as_csv
    field_names = Templates.all_child_field_names 
    csv = FasterCSV.generate do |rows|
      rows << field_names
      @results.each do |child|
        rows << field_names.map{ |field_name| child[field_name] } 
      end
    end

    send_data( csv, :filename => 'rapidftr_search_results.csv', :type => 'text/csv' )
  end

  def extract_relations_from_params(params)
    relations = params['relations'] 
    (relations && relations.values) || []
  end
end
