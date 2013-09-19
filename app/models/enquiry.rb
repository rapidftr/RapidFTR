class Enquiry < CouchRestRails::Document
  use_database :enquiry
  include RapidFTR::Model
  include RecordHelper
  include CouchRest::Validation
  before_save :find_matching_children

  property :reporter_name
  property :criteria
  property :potential_matches, :default => []
  property :reporter_details
  property :match_updated_at


  validates_presence_of :reporter_name, :message => I18n.t("errors.models.enquiry.presence_of_reporter_name")
  validates_presence_of :criteria, :message => I18n.t("errors.models.enquiry.presence_of_criteria")


  def self.new_with_user_name (user, *args)
    enquiry = new *args
    enquiry.set_creation_fields_for(user)
    enquiry
  end

  def update_from(properties)
    properties.each_pair do |name, value|
      if value.instance_of? HashWithIndifferentAccess
        self[name] = self[name].merge!(value)
      else
        self[name] = value
      end
    end
  end

  def find_matching_children
    children = MatchService.search_for_matching_children(self.criteria)
    self.potential_matches = children.map { |child| child.id }
    self.potential_matches.uniq!
  end

  def self.search_by_match_updated_since(timestamp)
    Enquiry.all.keep_if { |e|
      !e['match_updated_at'].nil? and DateTime.parse(e['match_updated_at']) >= timestamp
    }
  end

end
