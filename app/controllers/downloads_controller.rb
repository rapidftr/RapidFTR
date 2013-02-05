class DownloadsController < ApplicationController
  before_filter :current_user

  before_filter :validate_request
  before_filter :load_child_or_redirect, :only => [:child_data, :child_photo]

  include ChildrenHelper::Validations
  include ChildrenHelper::Utils


  # POST /children_data.pdf
  # POST /children_data.csv
  def children_data
    @children = find_children_by_user_access

    respond_to do |format|
      format.html
      format.csv do
        render_as_csv @children, @options
      end
      format.pdf do
        pdf_data = ExportGenerator.new(@options ,@children).to_full_pdf
        send_pdf(pdf_data, "#{file_basename}.pdf")
      end
    end

  end


  # POST /child_data.pdf
  # POST /child_data.csv
  def child_data
    respond_to do |format|
      format.html
      format.csv do
        render_as_csv([@child],@options)
      end

      format.pdf do
        pdf_data = ExportGenerator.new(@options, @child).to_full_pdf
        send_pdf(pdf_data, "#{file_basename(@child)}.pdf")
      end
    end
  end

  #POST /children_photos.csv
  #POST /children_photos.pdf
  def children_record
    selected_records = params["selections"] || {}
    if selected_records.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported')
    end

    children = selected_records.sort.map { |index, child_id| Child.get(child_id) }

    if params[:commit] == "Export to Photo Wall"
      children_photos_to_pdf(children, "#{file_basename}.pdf")
    elsif params[:commit] == "Export to PDF"
      pdf_data = ExportGenerator.new(@options, children).to_full_pdf
      send_pdf(pdf_data, "#{file_basename}.pdf")
    elsif params[:commit] == "Export to CSV"
      render_as_csv(children,@options)
    end
  end

  #POST /child_photo.pdf
  def child_photo
    respond_to do |format|
      format.pdf do
        pdf_data = ExportGenerator.new(@options, @child).to_photowall_pdf
        send_pdf(pdf_data, "#{file_basename(@child)}.pdf")
      end
    end
  end

  private

  def children_photos_to_pdf children, filename
    respond_to do |format|
      format.pdf do
        pdf_data = ExportGenerator.new(@options, children).to_photowall_pdf
        send_pdf(pdf_data, filename)
      end
    end
  end

  def validate_request
    authorize! :export, Child

    password = params[:password]
    raise ErrorResponse.bad_request('You must enter password to encrypt the exported file') unless password
    @options = {:encryption_options => {:user_password => password, :owner_password => password}}
  end
end