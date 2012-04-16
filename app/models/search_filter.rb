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

  alias super_to_lucene_query to_lucene_query
  def to_lucene_query
    if field2 == ""
      super_to_lucene_query
    else
      phrases = value.split(/\s+OR\s+/)
      phrases.map do |phrase|
        query1 = phrase.split(/[ ,]+/).map {|word| "(#{field}_text:#{word.downcase}~ OR #{field}_text:#{word.downcase}*)"}.join(" AND ")
        query2 = phrase.split(/[ ,]+/).map {|word| "(#{field2}_text:#{word.downcase}~ OR #{field2}_text:#{word.downcase}*)"}.join(" AND ")
        "(#{query1} OR #{query2})"
      end.join(" OR ")
    end
  end

end