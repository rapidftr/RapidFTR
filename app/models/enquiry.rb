class Enquiry < BaseModel
  use_database :enquiry

  require 'uuidtools'
  include Searchable

  after_initialize :create_unique_id

  before_validation :strip_whitespaces
  before_validation :create_criteria, :on => [:create, :update]

  after_save :find_matching_children

  property :short_id
  property :unique_identifier
  property :criteria, Hash
  property :match_updated_at, :default => ''
  property :updated_at, Time
  property :reunited, TrueClass, :default => false

  validate :validate_has_at_least_one_field_value

  FORM_NAME = 'Enquiries'

  set_callback :save, :before do
    self['updated_at'] = RapidFTR::Clock.current_formatted_time
  end

  design do
    view :by_created_by
    view :all, :map => "function(doc) {
                 if (doc['couchrest-type'] == 'Enquiry') {
                   emit(doc['_id'],1);
                 }
              }"

    view :by_user_name,
         :map => "function(doc) {
           if (doc.hasOwnProperty('histories')){
               for(var index=0; index<doc['histories'].length; index++){
                   emit(doc['histories'][index]['user_name'], doc)
               }
           }
           }"
  end

  def self.all_connected_with(user_name)
    (by_user_name(:key => user_name).all + by_created_by(:key => user_name).all).uniq { |enquiry| enquiry.unique_identifier }
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
    super
  end

  def self.build_text_fields_for_solar
    sortable_fields = FormSection.all_form_sections_for(Enquiry::FORM_NAME).map(&:all_sortable_fields).flatten.map(&:name)
    default_enquiry_fields + sortable_fields
  end

  def self.default_enquiry_fields
    %w(unique_identifier short_id created_by created_by_full_name last_updated_by last_updated_by_full_name created_organisation)
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
    potential_matches = PotentialMatch.by_enquiry_id_and_status.key([id, PotentialMatch::POTENTIAL]).all
    potential_matches.sort_by(&:score).reverse! || []
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
    hits = MatchService.search_for_matching_children(criteria)
    score_threshold = SystemVariable.find_by_name(SystemVariable::SCORE_THRESHOLD)

    potential_matches_to_mark_deleted = previous_matches.select { |pm| hits[pm.child_id].to_f < score_threshold.value.to_f }
    mark_potential_matches_as_deleted(potential_matches_to_mark_deleted)

    potential_matches.reject! { |pm| potential_matches_to_mark_deleted.include?(pm) }
    update_potential_matches_score(potential_matches, hits)

    previous_deleted_matches = PotentialMatch.by_enquiry_id_and_status.key([id, PotentialMatch::DELETED]).all
    previous_deleted_matches = previous_deleted_matches.select { |pm| hits[pm.child_id].to_f > score_threshold.value.to_f }

    previous_deleted_matches.each do |pm|
      next unless hits.keys.include?(pm.child_id)

      pm.score = hits[pm.child_id]
      pm.mark_as_potential_match
      pm.save!
    end

    hits.reject! { |_id, score| score.to_f < score_threshold.value.to_f }

    PotentialMatch.create_matches_for_enquiry id, hits
    verify_format_of(previous_matches)
    unless previous_matches.eql?(potential_matches)
      self.match_updated_at = Clock.now.to_s
    end
  end

  def mark_or_unmark_as_reunited(reunited)
    Enquiry.skip_callback(:save, :after, :find_matching_children)
    self['reunited'] = reunited
    save!

    if reunited
      matches = potential_matches
      matches.each do |match|
        match.mark_as_reunited_elsewhere
        match.save!
      end

      confirmed_match = PotentialMatch.by_enquiry_id_and_status.key([id, PotentialMatch::CONFIRMED]).first
      unless confirmed_match.nil?
        confirmed_match.mark_as_reunited
        confirmed_match.save!
      end
    else
      matches = PotentialMatch.by_enquiry_id.key(id).all
      matches.each do |match|
        if match.reunited_elsewhere?
          match.mark_as_potential_match
        elsif match.reunited?
          match.mark_as_confirmed
        end

        match.save!
      end
    end
    Enquiry.set_callback(:save, :after, :find_matching_children)
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

  def self.searchable_field_names
    Form.find_by_name(FORM_NAME).highlighted_fields.map(&:name) + [:unique_identifier, :short_id]
  end

  def confirmed_match
    PotentialMatch.by_enquiry_id_and_status.key([id, PotentialMatch::CONFIRMED]).first
  end

  def reunited_match
    PotentialMatch.by_enquiry_id_and_status.key([id, PotentialMatch::REUNITED]).first
  end

  def self.matchable_fields
    Array.new(FormSection.all_visible_child_fields_for_form(Enquiry::FORM_NAME)).keep_if { |field| field.matchable? }
  end

  def without_internal_fields
    delete 'histories'
    delete 'criteria'
    self
  end

  private

  def update_potential_matches_score(matches, hits)
    matches.each do |pm|
      if hits.keys.include?(pm.child_id)
        pm.score = hits[pm.child_id]
        pm.save!
      end
    end
  end

  def mark_potential_matches_as_deleted(matches)
    matches.each do |pm|
      pm.mark_as_deleted
      pm.save!
    end
  end

  def strip_whitespaces
    keys.each do |key|
      value = self[key]
      value.strip! if value.respond_to? :strip!
    end
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
