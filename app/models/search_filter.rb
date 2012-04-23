require 'pp'

###
# @author: jean.damore@gmail.com
# @date: 12/04/2012
# @description:
#  The Search Filter class is responsible for:
#    1. offsetting the search criteria index of +100 so as not to clash with standard search criteria
#    2. providing support for filtering on two fields e.g. created_by and created_by_full_name using an OR
##
class SearchFilter < SearchCriteria

  attr_accessor :field2
  OFFSET_INDEX = 100

  def initialize(params = {})
      super params
      @field2 = params[:field2] || ""
      @index = (@index.to_i + OFFSET_INDEX).to_s
  end

  def to_lucene_query
    query = create_query field, value
    (query += " OR " + create_query(field2, value)) if field2 != ""
    "(#{query})"
  end

  private
  def create_query field, search
      terms = search.split(/\s+(OR|AND)\s+/)
      terms.delete("OR")
      terms.delete("AND")
      terms.map do |term|
        query = term.split(/[ ,]+/).map {|word| "(#{field}_text:#{word.downcase}*)"}.join(" AND ")
        "(#{query})"
      end.join(" OR ")
    end

end