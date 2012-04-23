require "spec_helper"

describe SearchFilter do


  describe 'initialize' do

    let(:search_filter) {{:field => 'field', :field2 => 'field2', :index => '1'}}

    it 'should offset the index of OFFSET_INDEX' do
      filter = SearchFilter.new(search_filter)
      filter.index.should==(SearchFilter::OFFSET_INDEX+1).to_s
    end

    it 'should set the field2 value if provided in params' do
      filter = SearchFilter.new(search_filter)
      filter.field2.should==search_filter[:field2]
    end

  end

  describe 'to_lucene_query' do

    context 'simple query - one field' do

      let(:search_filter) {{:field => 'field', :value => 'me OR you'}}
      let(:lucene_query) { "(((field_text:me*)) OR ((field_text:you*)))" }

      it 'should return the correct lucene query' do
        filter = SearchFilter.new(search_filter)
        filter.to_lucene_query.should==lucene_query
      end

    end

    context 'simple query - two fields' do

      let(:search_filter) {{:field => 'field', :field2 => 'field2', :value => 'me OR you'}}
      let(:lucene_query) { "(((field_text:me*)) OR ((field_text:you*)) OR ((field2_text:me*)) OR ((field2_text:you*)))" }

      it 'should return the correct lucene query' do
        filter = SearchFilter.new(search_filter)
        filter.to_lucene_query.should==lucene_query
      end

    end

    context 'complex query - two fields' do

      let(:search_filter) {{:field => 'field', :field2 => 'field2', :value => 'john, me OR you AND tim'}}
      let(:lucene_query) { "(((field_text:john*) AND (field_text:me*)) OR ((field_text:you*)) OR ((field_text:tim*)) OR ((field2_text:john*) AND (field2_text:me*)) OR ((field2_text:you*)) OR ((field2_text:tim*)))" }

      it 'should return the correct lucene query' do
        filter = SearchFilter.new(search_filter)
        filter.to_lucene_query.should==lucene_query
      end

    end

  end


end