require 'spec_helper'

describe ExportGenerator do
	describe "when generating a CSV download" do
		subject do
			ExportGenerator.new( [
    		   Child.new( 'name' => 'Dave', 'unique_identifier' => "xxxy" ),
    	  	 Child.new( 'name' => 'Mary', 'unique_identifier' => "yyyx" )
   	 	]).to_csv
		end
		it 'should have a header for unique_identifier followed by all the user defined fields' do
			fields = Field.new_text_field("field_one"), Field.new_text_field("field_two")
			FormSection.stub!(:all_enabled_child_fields).and_return fields 
			csv_data =  FasterCSV.parse subject.data
		
    	headers = csv_data[0]
			headers.should == ["unique_identifier", "field_one", "field_two"]
  	end
		it 'should render a row for each result, plus a header row' do
			FormSection.stub!(:all_enabled_child_fields).and_return [Field.new_text_field("name")]
			csv_data = FasterCSV.parse subject.data
   		csv_data.length.should == 3
			csv_data[1][1].should == "Dave"
			csv_data[2][1].should == "Mary"
		end
		it "should add the correct mime type" do
			subject.options[:type].should == "text/csv"
		end
		it "should add the correct filename" do
      Clock.stub!(:now).and_return(Time.utc(2000, 1, 1, 20, 15))
			subject.options[:filename].should == "rapidftr-full-details-20000101.csv"			
		end
	end
	describe "when generating a CSV download for just one record" do
		subject do
			ExportGenerator.new( [
    	  	 Child.new( 'name' => 'Mary', 'unique_identifier' => "yyyx" )
   	 	]).to_csv
		end
		it "should add the unique id to the filename" do
			subject.options[:filename].should include "yyyx"
		end
	end
end
