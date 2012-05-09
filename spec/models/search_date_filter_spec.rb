require "spec_helper"

describe SearchDateFilter do

  let(:search_date_filter) {{:field => 'date', :from_value => 'from_value',  :to_value => 'to_value', :index => '1'}}

  describe 'initialize' do

    it 'should offset the index of OFFSET_INDEX' do
      range = SearchDateFilter.new(search_date_filter)
      range.index.should==(SearchDateFilter::OFFSET_INDEX+1).to_s
    end

    it 'should set the from_value as provided in params' do
      range = SearchDateFilter.new(search_date_filter)
      range.from_value.should==search_date_filter[:from_value]
    end

    it 'should set the to_value as provided in params' do
      range = SearchDateFilter.new(search_date_filter)
      range.to_value.should==search_date_filter[:to_value]
    end

  end

  describe 'to_lucene_query' do

    let(:lucene_query) { "(date_d:[from_value to_value])" }

    it 'should return the correct lucene query' do
      range = SearchDateFilter.new(search_date_filter)
      range.to_lucene_query.should==lucene_query
    end

  end

end