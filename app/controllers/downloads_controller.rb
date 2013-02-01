class DownloadsController < ApplicationController
  before_filter :current_user


  # POST /children_data.pdf
  # POST /children_data.csv
  def children_data
    authorize! :export, Child

    password = params[:password]
    raise ErrorResponse.bad_request('You must enter password to encrypt the exported file') unless password

    @children = find_by_user_access
    options = {:encryption_options => {:user_password => password, :owner_password => password}}
    respond_to do |format|
      format.csv do
        render_as_csv @children, "all_records_#{file_basename}.csv", options
      end
      format.pdf do
        pdf_data = ExportGenerator.new(options,@children).to_full_pdf
        send_pdf(pdf_data, "#{file_basename}.pdf")
      end
    end

  end


  # POST /child_data.pdf
  # POST /child_data.csv
  def child_data
    authorize! :export, Child
  end



  private

  def render_as_csv results, filename, options
    results = results || [] # previous version handled nils - needed?

    results.each do |child|
      child['photo_url'] = child_photo_url(child, child.primary_photo_id) unless child.primary_photo_id.nil?
      child['audio_url'] = child_audio_url(child)
    end

    export_generator = ExportGenerator.new(options, results)
    csv_data = export_generator.to_csv
    send_data(csv_data.data, csv_data.options)
  end

  def file_basename(child = nil)
    prefix = child.nil? ? current_user_name : child.short_id
    user = User.find_by_user_name(current_user_name)
    "#{prefix}-#{Clock.now.in_time_zone(user.time_zone).strftime('%Y%m%d-%H%M')}"
  end

  def find_by_user_access
    if can? :view_all, Child
      return Child.view(:by_all_view, :startkey => ["all"], :endkey => ["all", {}])
    else
      return Child.view(:by_all_view, :startkey => ["all", app_session.user_name], :endkey => ["all", app_session.user_name])
    end
  end

end