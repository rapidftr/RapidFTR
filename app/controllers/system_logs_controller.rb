class SystemLogsController < ApplicationController

  def index
    authorize! :manage, ContactInformation
    @page_name = t("admin.system_logs")

    @log_entries = LogEntry.by_created_at(:descending => true)
  end

end