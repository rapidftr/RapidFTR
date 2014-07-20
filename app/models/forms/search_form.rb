module Forms
  class SearchForm
    PER_PAGE = 20

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :ability, :params
    attr_reader   :criteria, :query, :results

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

      @query = params[:query]
    end

    def has_criteria?
      errors.add(:criteria, I18n.t("messages.valid_search_criteria")) unless @criteria.present? || @query.present?
    end

    def execute_search
      search = ChildSearch.new

      criteria.each do |criterion|
        search.fulltext_by [criterion[:field]], criterion[:value]
      end if criteria.count > 0

      search.fulltext_by [:created_organisation], params[:created_by_organisation_value]
      search.fulltext_by [:created_by, :created_by_full_name], params[:created_by_value]
      search.fulltext_by [:last_updated_by, :last_updated_by_full_name], params[:updated_by_value]

      search.less_than    :created_at, params[:created_at_before_value]
      search.greater_than :created_at, params[:created_at_after_value]
      search.less_than    :last_updated_at, params[:updated_at_before_value]
      search.greater_than :last_updated_at, params[:updated_at_after_value]

      search.fulltext_by FormSection.highlighted_fields.collect(&:name), params[:query] if params[:query]
      search.created_by ability.user unless ability.can? :view_all, Child
      search.paginated (params[:page] || 1).to_i, (params[:per_page] || PER_PAGE).to_i

      @results = search.results
    end

  end
end
