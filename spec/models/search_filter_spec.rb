require "spec_helper"

describe SearchFilter do

  let(:search_criteria) {{:field => 'field', :field2 => 'field2', :value => 'value', :join => 'AND', :index => '1'}}

  describe 'initialize' do

    it 'should offset the index of OFFSET_INDEX' do
      filter = SearchFilter.new(search_criteria)
      filter.index.should==(SearchFilter::OFFSET_INDEX+1).to_s
    end

    it 'should set the field2 value if provided in params' do
      filter = SearchFilter.new(search_criteria)
      filter.field2.should==search_criteria[:field2]
    end

  end

  describe 'to_lucene_query' do

    context 'no additional field provided' do

      it 'should call the super class to_lucene_query method' do

      end

    end

    context 'additional field provided'  do

      it 'should create a query to search on both fields with an OR' do

      end

    end

  end


end