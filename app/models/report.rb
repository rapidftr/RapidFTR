# This is a single "Report" document to be used for storing all kind of static, generated reports
# Alone - this Report document doesn't have any data except for the Type of report, Date of report, etc
# The actual report data should be attached as a document
# If you want multiple attachments - better create multiple Report objects

class Report < CouchRestRails::Document
  use_database :report
  include RapidFTR::Model
  include CouchRest::Validation

  validates_with_method :must_have_attached_report

  property :as_of_date, :cast_as => 'Date', :init_method => 'parse'
  property :report_type

  timestamps!

  view_by :as_of_date

  def file_name
    self['_attachments'].keys.first
  end

  def file_meta
    self['_attachments'][file_name]
  end

  def content_type
    file_meta["content_type"]
  end

  def data
    read_attachment file_name
  end

  def must_have_attached_report
    return true if self['_attachments'] && self['_attachments'].size == 1
    [ false, 'No report file attached!' ] # No need to translate since this is a background activity, not a user-facing activity
  end
end
