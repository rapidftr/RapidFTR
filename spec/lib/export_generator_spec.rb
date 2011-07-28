require 'spec_helper'

describe ExportGenerator do
	subject do
		ExportGenerator.new( [
       Child.new( 'name' => 'Dave', 'unique_identifier' => "xxxy" ),
       Child.new( 'name' => 'Mary', 'unique_identifier' => "yyyx" )
    ])
	end
	it 'should have a header for unique_identifier followed by all the user defined fields' do
		fields = Field.new_text_field("field_one"), Field.new_text_field("field_two")
		FormSection.stub!(:all_enabled_child_fields).and_return fields 
		csv_data =  FasterCSV.parse subject.to_csv
		
    headers = csv_data[0]
		headers.should == ["unique_identifier", "field_one", "field_two"]
  end
	it 'should render a row for each result, plus a header row' do
		FormSection.stub!(:all_enabled_child_fields).and_return [Field.new_text_field("name")]
		csv_data = FasterCSV.parse subject.to_csv
   	csv_data.length.should == 3
		csv_data[1][1].should == "Dave"
		csv_data[2][1].should == "Mary"
	end
end
