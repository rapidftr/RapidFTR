class SystemLogsController < ApplicationController

  def index
    authorize! :manage, ContactInformation

    @log_entries = LogEntry.by_created_at(:descending => true)
  end

end