module Forms
  class SearchForm
    PER_PAGE = 20
    SYSTEM_CRITERIA = [:created_by_organisation_value, :created_by_value, :updated_by_value, :created_at_before_value, :created_at_after_value, :updated_at_before_value, :updated_at_after_value]

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :ability, :params
    attr_reader :criteria, :system_criteria, :query, :results

    before_validation :parse_params
    validate :has_criteria?

    def execute
      execute_search if valid?
      self
    end

    private

    def parse_params
      criteria_hash = params[:criteria_list] || {}
      criteria_list = criteria_hash.is_a?(Hash) ? criteria_hash.values : criteria_hash

      @criteria = criteria_list.select do |criterion|
        (criterion[:value].present? && criterion[:field].present?) rescue false
      end

      @system_criteria = params.slice(*SYSTEM_CRITERIA).select { |_k, v| v.present? }

      @query = params[:query]
    end

    def has_criteria?
      errors.add(:criteria, I18n.t("messages.valid_search_criteria")) unless @criteria.present? || @system_criteria.present? || @query.present?
    end

    def execute_search
      search = ChildSearch.new

      @criteria.each do |criterion|
        search.fulltext_by [criterion[:field]], criterion[:value]
      end if criteria.count > 0

      search.fulltext_by([:created_organisation], @system_criteria[:created_by_organisation_value]) if @system_criteria[:created_by_organisation_value].present?
      search.fulltext_by([:created_by, :created_by_full_name], @system_criteria[:created_by_value]) if @system_criteria[:created_by_value].present?
      search.fulltext_by([:last_updated_by, :last_updated_by_full_name], @system_criteria[:updated_by_value]) if @system_criteria[:updated_by_value].present?

      search.less_than(:created_at, @system_criteria[:created_at_before_value]) if @system_criteria[:created_at_before_value].present?
      search.greater_than(:created_at, @system_criteria[:created_at_after_value]) if @system_criteria[:created_at_after_value].present?
      search.less_than(:last_updated_at, @system_criteria[:updated_at_before_value]) if @system_criteria[:updated_at_before_value].present?
      search.greater_than(:last_updated_at, @system_criteria[:updated_at_after_value]) if @system_criteria[:updated_at_after_value].present?

      search.fulltext_by((Form.find_by_name(Child::FORM_NAME).highlighted_fields.map(&:name)) + [:unique_identifier, :short_id], @query) if @query.present?

      search.created_by(ability.user) unless ability.can?(:view_all, Child)
      search.paginated((params[:page] || 1).to_i, (params[:per_page] || PER_PAGE).to_i)

      @results = search.results
    end
  end
end
