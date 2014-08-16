# This is a single "Report" document to be used for storing all kind of static, generated reports
# Alone - this Report document doesn't have any data except for the Type of report, Date of report, etc
# The actual report data should be attached as a document
# If you want multiple attachments - better create multiple Report objects

class Report < CouchRest::Model::Base
  use_database :report
  include RapidFTR::Model
  include RapidFTR::CouchRestRailsBackward

  validate :must_have_attached_report

  property :as_of_date, Date, :init_method => 'parse'
  property :report_type

  timestamps!

  design do
    view :by_as_of_date

    view :all,
         :map => "function(doc) {
             if (doc['couchrest-type'] == 'Report') {
               emit(doc._id, null);
             }
           }"
  end

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
    errors.add(:must_have_attached_report, 'No report file attached!') # No need to translate since this is a background activity, not a user-facing activity
  end
end
