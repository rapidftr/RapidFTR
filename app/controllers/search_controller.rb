class SearchController < ApplicationController
  PER_PAGE = 20
  def search
    @search_type = params[:search_type].nil? ? Child : params[:search_type].safe_constantize

    allowed_search_types = [Child]
    allowed_search_types << Enquiry if Enquiry.enquiries_enabled?

    if @search_type.nil? || !allowed_search_types.include?(@search_type)
      flash[:error] = I18n.t('messages.unknown_search_type')
      render :nothing => true, :status => 400
      return
    end

    authorize! :index, @search_type
    @page_name = t('search')
    query = params[:query]

    if query.nil? || query.empty?
      flash[:error] = I18n.t('messages.valid_search_criteria')
    else
      per_page = params[:per_page] || PER_PAGE
      per_page = per_page == 'all' ? @search_type.count : per_page.to_i
      page = params[:page] || 1
      
      search = Search.for(@search_type).paginated(page, per_page)
      search.created_by(current_user) unless can?(:view_all, @search_type)
      search.fulltext_by(@search_type.searchable_field_names, query)
      @results = search.results
      default_search_respond_to
    end
  end

  def default_search_respond_to
    respond_to do |format|
      format.html do
        if @search_type == Child && @results && @results.length == 1
          redirect_to child_path(@results.first)
        elsif @search_type == Enquiry && @results && @results.length == 1
          redirect_to enquiry_path(@results.first)
        end
      end

      respond_to_export(format, @results) if @search_type == Child
    end
  end

  def respond_to_export(format, children)
    RapidftrAddon::ExportTask.active.each do |export_task|
      format.any(export_task.id) do
        authorize! "export_#{export_task.id}".to_sym, Child
        LogEntry.create! :type => LogEntry::TYPE[export_task.id], :user_name => current_user.user_name, :organisation => current_user.organisation, :child_ids => children.map(&:id)
        results = export_task.new.export(children)
        encrypt_exported_files results, export_filename(children, export_task)
      end
    end
  end
end
