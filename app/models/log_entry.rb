class LogEntry < CouchRestRails::Document
  use_database :log_entry
  before_save :set_created_at

  TYPE = {:cpims => "CPIMS Export", :csv => "CSV Export", :pdf => "PDF Export", :photowall => "Photo Wall Export"}

  def set_created_at
     self[:created_at] = RapidFTR::Clock.current_formatted_time
  end

    view_by :created_at,
          :map => "function(doc) {
                if ((doc['couchrest-type'] == 'LogEntry') && doc['created_at'])
                {
                     emit(doc['created_at'],doc);
                }
          }"


end