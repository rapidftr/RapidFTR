class ChildrenController < ApplicationController

  # GET /children
  # GET /children.xml
  def index
    @page_name = "Listing children"
    @children = Child.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @children }
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
    end
  end

  # GET /children/new
  # GET /children/new.xml
  def new
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
    @page_name = "Edit child record"
    @child = Child.get(params[:id])
    @form_sections = get_form_sections_for_child @child
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
      else
        format.html {
          @form_sections = get_form_sections_for_child @child
          render :action => "new"
        }
        format.xml  { render :xml => @child.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new_search

  end

  # PUT /children/1
  # PUT /children/1.xml
  def update
    @child = Child.get(params[:id])
    new_photo = params[:child].delete(:photo)
    @child.update_properties_with_user_name current_user_name, new_photo, params[:child]
    
    respond_to do |format|
      if @child.save
        flash[:notice] = 'Child was successfully updated.'
        format.html { redirect_to(@child) }
        format.xml  { head :ok }
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
    @child = Child.find(params[:id])
    @child.destroy

    respond_to do |format|
      format.html { redirect_to(children_url) }
      format.xml  { head :ok }
    end
  end

  def search
    @show_thumbnails = !!params[:show_thumbnails]
    @results = Summary.basic_search(params[:child_name], params[:unique_identifier])
    if 1 == @results.length
      redirect_to child_path( @results.first )
    end
  end

  def photo_pdf
    @child = Child.get(params[:id])
    pdf_data = PdfGenerator.new.child_photo(@child)
    send_data pdf_data, :filename => "photos.pdf", :type => "application/pdf"
  end

  private

  def get_form_sections_for_child child
  forms = []
    Templates.child_form_section_names.each do |section_name|
      forms << FormSection.create_form_section_from_template(section_name, Templates.get_template(section_name), child)
    end
    return forms
  end
end
