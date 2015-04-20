class Child < BaseModel
  use_database :child

  require 'uuidtools'
  include Extensions::CustomValidator::CustomFieldsValidator
  include Searchable

  after_initialize :create_unique_id
  after_save :find_matching_enquiries
  after_save :mark_or_unmark_confirmed_enquiry_reunited

  property :short_id
  property :unique_identifier
  property :created_organisation
  property :created_by
  property :reunited, TrueClass
  property :flag, TrueClass
  property :duplicate, TrueClass
  property :investigated, TrueClass
  property :verified, TrueClass

  validates_with FieldValidator, :type => Field::NUMERIC_FIELD
  validate :validate_duplicate_of
  validates_with FieldValidator, :type => Field::TEXT_AREA
  validates_with FieldValidator, :type => Field::TEXT_FIELD
  validate :validate_created_at
  validate :validate_has_at_least_one_field_value
  validate :validate_last_updated_at

  FORM_NAME = 'Children'

  def self.build_text_fields_for_solar
    sortable_fields = FormSection.all_form_sections_for(Child::FORM_NAME).map(&:all_sortable_fields).flatten.map(&:name)
    default_child_fields + sortable_fields
  end

  def self.default_child_fields
    %w(unique_identifier short_id created_by created_by_full_name last_updated_by last_updated_by_full_name created_organisation)
  end

  def self.build_date_fields_for_solar
    %w(created_at last_updated_at reunited_at flag_at)
  end

  def self.sortable_field_name(field)
    "#{field}_sort".to_sym
  end

  @set_up_solr_fields = proc do
    text_fields = Child.build_text_fields_for_solar
    date_fields = Child.build_date_fields_for_solar

    text_fields.each do |field_name|
      string Child.sortable_field_name(field_name) do
        self[field_name]
      end
      text field_name
    end
    date_fields.each do |field_name|
      time field_name
      # TODO: Not needed but for compatibility with sortable_field_name
      time Child.sortable_field_name(field_name) do
        self[field_name]
      end
    end

    boolean :duplicate
    boolean(:active) { |c| !c.duplicate && !c.reunited }
    boolean :reunited
    boolean :flag
  end

  searchable(&@set_up_solr_fields)

  def self.update_solr_indices
    Sunspot.setup(Child, &@set_up_solr_fields)
  end

  design do
    view :by_protection_status_and_gender_and_ftr_status
    view :by_unique_identifier
    view :by_short_id
    view :by_created_by
    view :by_duplicate_of

    view :by_flag,
         :map => "function(doc) {
               if (doc.hasOwnProperty('flag'))
               {
                   if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                   emit(doc['flag'],doc);
                   }
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

    # TODO: Use Child.database.documents['rows'] and map that instead
    #   (unless this map function needs to do further filtering by duplicate/etc)
    #   Firstly, do we even need to sync duplicate records?
    view :by_ids_and_revs,
         :map => "function(doc) {
       if (doc['couchrest-type'] == 'Child'){
       emit(doc._id, {_id: doc._id, _rev: doc._rev});
       }
     }"
  end

  def without_internal_fields
    self['current_photo_key'] = '' if self['current_photo_key'].nil?
    delete 'histories'
    self
  end

  def self.fetch_all_ids_and_revs
    ids_and_revs = []
    all_rows = by_ids_and_revs(:include_docs => false)['rows']
    all_rows.each do |row|
      ids_and_revs << row['value']
    end
    ids_and_revs
  end

  def form
    Form.find_by_name(form_name)
  end

  def form_name
    Child::FORM_NAME
  end

  def validate_has_at_least_one_field_value
    return true if field_definitions_for(Child::FORM_NAME).any? { |field| filled_in?(field) }
    return true if !@file_name.nil? || !@audio_file_name.nil?
    return true if unknown_fields && unknown_fields.any? { |_key, value| !value.nil? && value != [] && value != {} && !value.to_s.empty? }
    errors.add(:validate_has_at_least_one_field_value, I18n.t('errors.models.child.at_least_one_field'))
  end

  def validate_age
    return true if age.nil? || age.blank? || !age.number? || (age =~ /^\d{1,2}(\.\d)?$/ && age.to_f > 0 && age.to_f < 100)
    errors.add(:age, I18n.t('errors.models.child.age'))
  end

  def validate_created_at
    if self['created_at']
      DateTime.parse self['created_at']
    end
    true
rescue
  errors.add(:created_at, '')
  end

  def validate_last_updated_at
    if self['last_updated_at']
      DateTime.parse self['last_updated_at']
    end
    true
rescue
  errors.add(:last_updated_at, '')
  end

  def self.flagged
    by_flag(:key => true)
  end

  def self.all_connected_with(user_name)
    # TODO: Investigate why the hash of the objects got different.
    (by_user_name(:key => user_name).all + by_created_by(:key => user_name).all).uniq { |child| child.unique_identifier }
  end

  def has_one_interviewer?
    user_names_after_deletion = self['histories'].map { |change| change['user_name'] }
    user_names_after_deletion.delete(self['created_by'])
    self['last_updated_by'].blank? || user_names_after_deletion.blank?
  end

  def mark_as_duplicate(parent_id)
    self['duplicate'] = true
    self['duplicate_of'] = Child.by_short_id(:key => parent_id).first.try(:id)
  end

  def confirmed_matches
    potential_matches = PotentialMatch.by_child_id_and_status.key([id, PotentialMatch::CONFIRMED]).all
    potential_matches.sort_by(&:score).reverse! || []
  end

  def reunited_matches
    potential_matches = PotentialMatch.by_child_id_and_status.key([id, PotentialMatch::REUNITED]).all
    potential_matches.sort_by(&:score).reverse! || []
  end

  def potential_matches
    potential_matches = PotentialMatch.by_child_id_and_status.key([id, PotentialMatch::POTENTIAL]).all
    potential_matches.sort_by(&:score).reverse! || []
  end

  def find_matching_enquiries
    previous_matches = potential_matches
    criteria = Child.matchable_fields.map do |field|
      field_name = field.name
      self[field_name] unless self[field_name].nil?
    end
    criteria.reject! { |c| c.nil? || c.empty? }
    hits = MatchService.search_for_matching_enquiries(criteria)
    PotentialMatch.update_matches_for_child id, hits

    unless previous_matches.eql?(potential_matches)
      self.match_updated_at = Clock.now.to_s
    end
  end

  def self.schedule(scheduler)
    scheduler.every('24h') do
      Child.reindex!
    end
  end

  def self.searchable_field_names
    Form.find_by_name(FORM_NAME).highlighted_fields.map(&:name) + [:unique_identifier, :short_id]
  end

  def self.matchable_fields
    Array.new(FormSection.all_visible_child_fields_for_form(Child::FORM_NAME)).keep_if { |field| field.matchable? }
  end

  def without_updating_matches
    Child.skip_callback(:save, :after, :find_matching_enquiries)
    yield
    Child.set_callback(:save, :after, :find_matching_enquiries)
  end

  private

  def mark_or_unmark_confirmed_enquiry_reunited
    return if self[:reunited].nil?
    if self[:reunited]
      matches = PotentialMatch.by_child_id_and_status.key([id, PotentialMatch::CONFIRMED]).all
      matches.each do |match|
        match.enquiry.mark_or_unmark_as_reunited(self[:reunited])
      end
    else
      matches = PotentialMatch.by_child_id_and_status.key([id, PotentialMatch::REUNITED]).all
      matches.each do |match|
        match.enquiry.mark_or_unmark_as_reunited(self[:reunited])
      end
    end
  end

  def unknown_fields
    system_fields = ['created_at',
                     'last_updated_at',
                     'last_updated_by',
                     'last_updated_by_full_name',
                     'posted_at',
                     'posted_from',
                     '_rev',
                     '_id',
                     '_attachments',
                     'short_id',
                     'created_by',
                     'created_by_full_name',
                     'couchrest-type',
                     'histories',
                     'unique_identifier',
                     'created_organisation']
    existing_fields = system_fields + field_definitions_for(Child::FORM_NAME).map { |x| x.name }
    reject { |k, _v| existing_fields.include? k }
  end

  def validate_duplicate_of
    return errors.add(:duplicate, I18n.t('errors.models.child.validate_duplicate')) if self['duplicate'] && self['duplicate_of'].blank?
  end
end
