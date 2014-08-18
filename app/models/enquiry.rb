class Enquiry < CouchRest::Model::Base
  use_database :enquiry
  include RecordHelper

  before_validation :create_criteria, :on => [:create, :update]
  before_save :find_matching_children

  property :criteria, Hash
  property :potential_matches, :default => []
  property :match_updated_at, :default => ""

  validates :criteria, :presence => {:message => I18n.t("errors.models.enquiry.presence_of_criteria")}
  validate :validate_has_at_least_one_field_value

  FORM_NAME = "Enquiries"

  design do
    view :all,
         :map => "function(doc) {
          if (doc['couchrest-type'] == 'Enquiry') {
            emit(doc['_id'],1);
          }
        }"
  end

  def validate_has_at_least_one_field_value
    return true if field_definitions_for(Enquiry::FORM_NAME).any? { |field| is_filled_in?(field) }
    errors.add(:validate_has_at_least_one_field_value, I18n.t("errors.models.enquiry.at_least_one_field"))
  end

  def method_missing(m, *args)
    if m.to_s.match(/=$/)
      return self[m.to_s[0..-2]] = args[0]
    end
    self[m]
  end

  def self.new_with_user_name(user, *args)
    enquiry = new(*args)
    enquiry.creation_fields_for(user)
    enquiry
  end

  def update_from(properties)
    attributes_to_update = {}
    properties.each_pair do |name, value|
      if value.instance_of?(HashWithIndifferentAccess) || value.instance_of?(ActionController::Parameters)
        attributes_to_update[name] = self[name] if attributes_to_update[name].nil?
        # Don't change the code to use merge!
        # It will break the access to dynamic attributes.
        attributes_to_update[name] = attributes_to_update[name].merge(value)
      else
        attributes_to_update[name] = value
      end
    end
    self.attributes = attributes_to_update unless attributes_to_update.empty?
  end

  def find_matching_children
    previous_matches = potential_matches
    children = MatchService.search_for_matching_children(criteria)
    self.potential_matches = children.map { |child| child.id }
    verify_format_of(previous_matches)

    unless previous_matches.eql?(potential_matches)
      self.match_updated_at = Clock.now.to_s
    end
  end

  def self.search_by_match_updated_since(timestamp)
    Enquiry.all.all.select do |e|
      !e['match_updated_at'].empty? && DateTime.parse(e['match_updated_at']) >= timestamp
    end
  end

  private

  def create_criteria
    self.criteria = {}
    fields = Array.new(field_definitions_for(Enquiry::FORM_NAME)).keep_if { |field| is_filled_in?(field) }
    fields.each do |field|
      criteria.store(field.name, self[field.name])
    end
  end

  def verify_format_of(previous_matches)
    unless previous_matches.is_a?(Array)
      previous_matches = JSON.parse(previous_matches)
    end
    previous_matches
  end
end
