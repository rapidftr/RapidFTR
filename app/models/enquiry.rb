class Enquiry < CouchRest::Model::Base
  use_database :enquiry

  require 'uuidtools'
  include RecordHelper
  include RapidFTR::CouchRestRailsBackward
  include Searchable

  after_initialize :create_unique_id

  before_validation :strip_whitespaces
  before_validation :create_criteria, :on => [:create, :update]
  after_save :find_matching_children
  before_save :update_history, :unless => :new?
  before_save :add_creation_history, :if => :new?

  property :short_id
  property :unique_identifier
  property :criteria, Hash
  property :match_updated_at, :default => ''
  property :updated_at, Time

  validate :validate_has_at_least_one_field_value

  FORM_NAME = 'Enquiries'

  set_callback :save, :before do
    self['updated_at'] = RapidFTR::Clock.current_formatted_time
  end

  def initialize(*args)
    self['histories'] = []
    super(*args)
  end

  design do
    view :all, :map => "function(doc) {
                 if (doc['couchrest-type'] == 'Enquiry') {
                   emit(doc['_id'],1);
                 }
              }"
  end

  def self.sortable_field_name(field)
    "#{field}_sort".to_sym
  end

  def validate_has_at_least_one_field_value
    return true if field_definitions_for(Enquiry::FORM_NAME).any? { |field| filled_in?(field) }
    errors.add(:validate_has_at_least_one_field_value, I18n.t('errors.models.enquiry.at_least_one_field'))
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

  def self.build_text_fields_for_solar
    sortable_fields = FormSection.all_sortable_field_names || []
    default_enquiry_fields + sortable_fields
  end

  def self.default_enquiry_fields
    %w(unique_identifier created_by created_by_full_name last_updated_by last_updated_by_full_name created_organisation)
  end

  def self.build_date_fields_for_solar
    %w(created_at last_updated_at)
  end

  @set_up_solr_fields = proc do
    text_fields = Enquiry.build_text_fields_for_solar
    date_fields = Enquiry.build_date_fields_for_solar

    text_fields.each do |field_name|
      string Enquiry.sortable_field_name(field_name) do
        self[field_name]
      end
      text field_name
    end
    date_fields.each do |field_name|
      time field_name
      time Enquiry.sortable_field_name(field_name) do
        self[field_name]
      end
    end
  end

  searchable(&@set_up_solr_fields)

  def self.update_solr_indices
    Sunspot.setup(Enquiry, &@set_up_solr_fields)
  end

  def potential_matches
    potential_matches = PotentialMatch.by_enquiry_id.key(id).all
    potential_matches.reject! { |pm| pm.marked_invalid? }
    child_ids = potential_matches.each.map(&:child_id)
    child_ids.map { |id| Child.get(id) }
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
    PotentialMatch.create_matches_for_enquiry id, children.map(&:id)
    verify_format_of(previous_matches)

    unless previous_matches.eql?(potential_matches)
      self.match_updated_at = Clock.now.to_s
    end
  end

  def self.update_all_child_matches
    Enquiry.skip_callback(:save, :after, :find_matching_children)
    all.each do |enquiry|
      enquiry.create_criteria
      enquiry.find_matching_children
      enquiry.save
    end
    Enquiry.set_callback(:save, :after, :find_matching_children)
  end

  def self.search_by_match_updated_since(timestamp)
    Enquiry.all.all.select do |e|
      !e['match_updated_at'].empty? && DateTime.parse(e['match_updated_at']) >= timestamp
    end
  end

  def create_criteria
    self.criteria = {}
    fields = Array.new(field_definitions_for(Enquiry::FORM_NAME)).keep_if { |field| filled_in?(field) && field.matchable? }
    fields.each do |field|
      criteria.store(field.name, self[field.name])
    end
  end

  private

  def strip_whitespaces
    keys.each do |key|
      value = self[key]
      value.strip! if value.respond_to? :strip!
    end
  end

  def create_unique_id
    self.unique_identifier ||= UUIDTools::UUID.random_create.to_s
    self.short_id = unique_identifier.last 7
  end

  def verify_format_of(previous_matches)
    unless previous_matches.is_a?(Array)
      previous_matches = JSON.parse(previous_matches)
    end
    previous_matches
  end

  class << self
    def with_child_potential_matches(options = {})
      options[:page] ||= 1
      options[:per_page] ||= EnquiriesHelper::View::PER_PAGE

      WillPaginate::Collection.create(options[:page], options[:per_page]) do |pager|
        PotentialMatch.paginates_per options.delete(:per_page)
        page = options.delete(:page)
        results = PotentialMatch.
                    all_valid_enquiry_ids(options).
                    page(page).
                    reduce.
                    group.
                    rows
        pager.replace(results.map { |r| Enquiry.find(r['key']) })
        pager.total_entries = PotentialMatch.all_valid_enquiry_ids.reduce.group.rows.count
      end
    end
  end
end
