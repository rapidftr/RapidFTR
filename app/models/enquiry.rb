class Enquiry < CouchRest::Model::Base
  use_database :enquiry
  include RecordHelper

  before_save :find_matching_children

  property :enquirer_name
  property :criteria, Hash
  property :potential_matches, :default => []
  property :match_updated_at, :default => ""


  validates_presence_of :enquirer_name, :message => I18n.t("errors.models.enquiry.presence_of_enquirer_name")
  validates_presence_of :criteria, :message => I18n.t("errors.models.enquiry.presence_of_criteria")

  FORM_NAME = "Enquiries"

  design do
    view :all,
      :map => "function(doc) {
          if (doc['couchrest-type'] == 'Enquiry') {
            emit(doc['_id'],1);
          }
        }"
  end

  def self.new_with_user_name (user, *args)
    enquiry = new *args
    enquiry.set_creation_fields_for(user)
    enquiry
  end

  def update_from(properties)
    attributes_to_update = {}
    properties.each_pair do |name, value|
      if value.instance_of? HashWithIndifferentAccess or value.instance_of? ActionController::Parameters
        attributes_to_update[name] = self[name] if attributes_to_update[name].nil?
        #Don't change the code to use merge!
        #It will break the access to dynamic attributes.
        attributes_to_update[name] = attributes_to_update[name].merge(value)
      else
        attributes_to_update[name] = value
      end
    end
    self.attributes = attributes_to_update unless attributes_to_update.empty?
  end

  def find_matching_children
    previous_matches = self.potential_matches
    children = MatchService.search_for_matching_children(self.criteria)
    self.potential_matches = children.map { |child| child.id }
    verify_format_of(previous_matches)

    unless previous_matches.eql?(self.potential_matches)
      self.match_updated_at = Clock.now.to_s
    end
  end

  def self.search_by_match_updated_since(timestamp)
    Enquiry.all.all.select { |e|
      !e['match_updated_at'].empty? and DateTime.parse(e['match_updated_at']) >= timestamp
    }
  end

  private

  def verify_format_of(previous_matches)
    unless previous_matches.is_a?(Array)
      previous_matches = JSON.parse(previous_matches)
    end
    previous_matches
  end

end
