class LogEntry < CouchRestRails::Document
  use_database :log_entry

  TYPE = {:cpims_export => "CPIMS_Export"}

end