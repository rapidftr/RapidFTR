class SearchController < ApplicationController
  def search
    authorize! :index, Child
    @page_name = t('search')
    query = params[:query]

    if query.nil? || query.empty?
      flash[:error] = I18n.t('messages.valid_search_criteria')
      render 'children/search'
    else
      search_type = params[:search_type].constantize
      search = Search.for(search_type)
      search.created_by(current_user.user_name) unless can?(:view_all, Child)
      search.fulltext_by((Form.find_by_name(Child::FORM_NAME).highlighted_fields.map(&:name)) + [:unique_identifier, :short_id], query)
      @results = search.results
      default_search_respond_to
    end
  end

  def default_search_respond_to
    respond_to do |format|
      format.html do
        if @results && @results.length == 1
          redirect_to child_path(@results.first)
        end
      end

      respond_to_export format, @results
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
