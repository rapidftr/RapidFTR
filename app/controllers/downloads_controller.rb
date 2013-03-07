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
        pdf_data = ExportGenerator.new(@options, @children).to_full_pdf
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
        render_as_csv([@child], @options)
      end

      format.pdf do
        pdf_data = ExportGenerator.new(@options, @child).to_full_pdf
        send_pdf(pdf_data, "#{file_basename(@child)}.pdf")
      end
    end
  end

  #POST /children_record.csv
  #POST /children_record.pdf
  def children_record
    authorize! :export, Child
    selected_records = params["selections"] || {} if params["all"] != "Select all records"
    selected_records = params["full_results"].split(/,/) if params["all"] == "Select all records"
    if selected_records.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported')
    end

    children = []
    children = selected_records.sort.map { |index, child_id| Child.get(child_id) } if params["all"].nil?
    selected_records.each do |child_id|
      children.push(Child.get(child_id))
    end if params["all"] == "Select all records"

    respond_to do |format|
      format.csv do
        if params[:commit] == t("child.actions.export_to_csv")
          render_as_csv(children, @options)
        end
      end
      format.pdf do
        if params[:commit] == t("child.actions.export_to_photo_wall")
          export_to_photo_wall(children, "#{file_basename}.pdf")
        elsif params[:commit] == t("child.actions.export_to_pdf")
          export_all(children)
        end
      end
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

  def export_to_photo_wall children, filename
    pdf_data = ExportGenerator.new(@options, children).to_photowall_pdf
    send_pdf(pdf_data, filename)
  end

  def export_all(children)
    pdf_data = ExportGenerator.new(@options, children).to_full_pdf
    send_pdf(pdf_data, "#{file_basename}.pdf")
  end

  def validate_request
    authorize! :export, Child

    password = params[:password]
    raise ErrorResponse.bad_request('You must enter password to encrypt the exported file') unless password
    @options = {:password => password}
  end
end