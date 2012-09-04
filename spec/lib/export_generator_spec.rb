require 'spec_helper'

describe ExportGenerator do
  describe "when generating a CSV download" do
    describe "with just a name field" do
      subject do
        ExportGenerator.new( [
                              Child.new(
                                '_id' => '3-123451', 'name' => 'Dave', 'unique_identifier' => "xxxy",
                                'photo_url' => 'http://testmachine:3000/some-photo-path/1',
                                'audio_url' => 'http://testmachine:3000/some-audio-path/1',
                                'current_photo_key' => "photo-some-id-1", 'some_audio' => 'audio-some-id-1' ),
                              Child.new(
                                '_id' => '4-153213', 'name' => 'Mary', 'unique_identifier' => "yyyx",
                                'photo_url' => 'http://testmachine:3000/some-photo-path/2',
                                'audio_url' => 'http://testmachine:3000/some-audio-path/2',
                                'current_photo_key' => "photo-some-id-2", 'some_audio' => 'audio-some-id-2' )
                             ]).to_csv
      end

      it 'should have a header for unique_identifier followed by all the user defined fields' do
        fields = Field.new_text_field("field_one"), Field.new_text_field("field_two")
        FormSection.stub!(:all_enabled_child_fields).and_return fields
        csv_data =  CSV.parse subject.data

        headers = csv_data[0]
        headers.should == ["unique_identifier", "field_one", "field_two", "Suspect Status", "Reunited Status"]
      end

      it 'should render a row for each result, plus a header row' do
        FormSection.stub!(:all_enabled_child_fields).and_return [Field.new_text_field("name")]
        csv_data = CSV.parse subject.data
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

      it 'should have a photo column with appropriate links' do
        FormSection.stub!(:all_enabled_child_fields).and_return [Field.new_text_field('_id'), Field.new_text_field("name"), Field.new_text_field("current_photo_key")]
        csv_data = CSV.parse subject.data
        csv_data[1][3].should == "http://testmachine:3000/some-photo-path/1"
        csv_data[2][3].should == "http://testmachine:3000/some-photo-path/2"
        csv_data.length.should == 3
      end

      it 'should have an audio column with appropriate links' do
        FormSection.stub!(:all_enabled_child_fields).and_return [Field.new_text_field('_id'), Field.new_text_field("name"), Field.new_text_field("some_audio")]
        csv_data = CSV.parse subject.data
        csv_data[1][3].should == "http://testmachine:3000/some-audio-path/1"
        csv_data[2][3].should == "http://testmachine:3000/some-audio-path/2"
        csv_data.length.should == 3
      end
    end

    describe "with a multi checkbox field" do
      subject do
        FormSection.stub!(:all_enabled_child_fields).and_return [Field.new_check_boxes_field("multi")]
        ExportGenerator.new( [
                              Child.new( 'multi' => ["Dogs", "Cats"], 'unique_identifier' => "xxxy" ),
                              Child.new( 'multi' => nil, 'unique_identifier' => "xxxy" ),
                              Child.new( 'multi' => ["Cats", "Fish"], 'unique_identifier' => "yyyx" )
                             ]).to_csv
      end

      it "should render multi checkbox fields as a comma separated list" do
        csv_data = CSV.parse subject.data
        csv_data[1][1].should == "Dogs, Cats"
        csv_data[2][1].should == ""
        csv_data[3][1].should == "Cats, Fish"
      end
    end

    describe "for just one record" do
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
end
