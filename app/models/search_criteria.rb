class SearchCriteria
  attr_accessor :index, :value, :join, :field, :field_display_name
  
  def initialize(params = {})
    @join = params[:join] || ""
    @field_display_name = params[:display_name] || ""
    @index = params[:index] || 0   
    @field = params[:field] || ""
    @value = (params[:value] || "").strip
  end

  def self.create_advanced_criteria(criteria)
    SearchCriteria.new(:field => criteria[:field], :value => criteria[:value], :join => "AND", :index => criteria[:index].to_s)
  end
  
  def self.build_from_params(criteria_list)
    text_fields =  FormSection.all.map{ |form| form.all_text_fields }.flatten
    isAllSearch = false
    allSearchCriteria = ""
    allSearchBeginIndex = 1000

    criteria_list.map do |index, criteria_params|
      if (criteria_params[:field] == "ALL")
        
        allSearchCriteria = criteria_params[:value]

        
        text_fields.map do |text_field| 
          if (text_field.type.include? "text")
            criteria_params[:field] = text_field.name
            criteria_params[:value] = allSearchCriteria
            criteria_params[:index] = allSearchBeginIndex
            criteria_params[:display_name] = text_field.display_name
            criteria_params[:join] = "OR"
            SearchCriteria.new(criteria_params)
            allSearchBeginIndex = allSearchBeginIndex + 1
          end
        end
        next
      else

        field = text_fields.detect { |text_field| text_field.name == criteria_params[:field] }
        criteria_params[:display_name] = field.display_name_for_field_selector  
        SearchCriteria.new(criteria_params)
      end
    end.sort_by(&:index)

  end
  
  def self.lucene_query(criteria_list)
    throw criteria_list
    criteria_list = criteria_list.clone
    criteria = criteria_list.shift
    build_joins(criteria_list, criteria.to_lucene_query)
  end
  
  # for text based fields
  def to_lucene_query
    phrases = value.split(/\s+OR\s+/)
    phrases.map do |phrase|
      query = phrase.split(/[ ,]+/).map {|word| "(#{field}_text:#{word.downcase}~ OR #{field}_text:#{word.downcase}*)"}.join(" AND ")
      "(#{query})" 
    end.join(" OR ")
  end
  
  private 
  def self.build_joins(list, lucene_query)
    query = lucene_query.to_s
    criteria = list.shift
    
    return query if criteria.nil?

    if criteria.join == "AND"
      query = "(#{query} AND #{criteria.to_lucene_query})"
      return build_joins(list, query)
    end
    
    if criteria.join == "OR"
      return "#{query} OR #{build_joins(list, criteria.to_lucene_query)}"
    end
  end
  
end
