require 'spec_helper'

describe ExportGenerator do
  describe "when generating a CSV download" do
    describe "with just a name field" do

      before(:each) do
        @user = User.new(
            :user_name=>'user',
            :full_name=>'name',
            :organisation=>"UNICEF"
        )

        @child1 = Child.new_with_user_name(@user,
          '_id' => '3-123451', 'name' => 'Dave', 'unique_identifier' => "xxxy",
          'photo_url' => 'http://testmachine:3000/some-photo-path/1',
          'audio_url' => 'http://testmachine:3000/some-audio-path/1',
          'current_photo_key' => "photo-some-id-1", 'some_audio' => 'audio-some-id-1')
        @child1.create_unique_id

        @child2 = Child.new_with_user_name(@user,
          '_id' => '4-153213', 'name' => 'Mary', 'unique_identifier' => "yyyx", 
          'photo_url' => 'http://testmachine:3000/some-photo-path/2',
          'audio_url' => 'http://testmachine:3000/some-audio-path/2',
          'current_photo_key' => "photo-some-id-2", 'some_audio' => 'audio-some-id-2' )
        @child2.create_unique_id

        @child3 = Child.new_with_user_name(@user,
                                          '_id' => '5-188888', 'name' => 'Jane', 'unique_identifier' => "yxyy",
                                          'photo_url' => 'http://testmachine:3000/some-photo-path/3',
                                          'audio_url' => 'http://testmachine:3000/some-audio-path/3',
                                          'current_photo_key' => "photo-some-id-2", 'some_audio' => 'audio-some-id-2' )
        @child3.create_unique_id
      end
        
      subject do
        ExportGenerator.new( [@child1, @child2, @child3]).to_csv
      end
      
      it 'should have a header for unique_identifier followed by all the user defined fields and metadata fields' do
        fields = Field.new_text_field("field_one"), Field.new_text_field("field_two")
        FormSection.stub!(:all_visible_child_fields).and_return fields 
        csv_data =  FasterCSV.parse subject.data
        
        headers = csv_data[0]
        headers.should == ["Unique identifier", "Short", "Field one", "Field two", "Suspect status", "Reunited status", "Created by", "Created organisation", "Posted at", "Last updated by full name", "Last updated at"]
      end
      
      it 'should render a row for each result, plus a header row' do
        FormSection.stub!(:all_visible_child_fields).and_return [Field.new_text_field("name")]
        csv_data = FasterCSV.parse subject.data
        csv_data.length.should == 4
        csv_data[1][0].should == "xxxy"
        csv_data[1][2].should == "Dave"
        csv_data[2][0].should == "yyyx"
        csv_data[3][0].should == "yxyy"
      end
      
      it "should add the correct mime type" do
        subject.options[:type].should == "text/csv"
      end
      
      it "should add the correct filename" do
        Clock.stub!(:now).and_return(Time.utc(2000, 1, 1, 20, 15))
        subject.options[:filename].should == "rapidftr-full-details-20000101.csv"      
      end
      
      it 'should have a photo column with appropriate links' do        
        FormSection.stub!(:all_visible_child_fields).and_return [Field.new_text_field('_id'), Field.new_text_field("name"), Field.new_text_field("current_photo_key")]
        csv_data = FasterCSV.parse subject.data
        csv_data[1][4].should == "http://testmachine:3000/some-photo-path/1"
        csv_data[2][4].should == "http://testmachine:3000/some-photo-path/2"
        csv_data[3][4].should == "http://testmachine:3000/some-photo-path/3"
        csv_data.length.should == 4
      end
      
      it 'should have an audio column with appropriate links' do
        FormSection.stub!(:all_visible_child_fields).and_return [Field.new_text_field('_id'), Field.new_text_field("name"), Field.new_text_field("some_audio")]
        csv_data = FasterCSV.parse subject.data
        csv_data[1][4].should == "http://testmachine:3000/some-audio-path/1"
        csv_data[2][4].should == "http://testmachine:3000/some-audio-path/2"
        csv_data.length.should == 4
      end

      it "should add metadata of children at the end" do
        csv_data = FasterCSV.parse subject.data
        index = csv_data[0].index "Created by"
        csv_data[1][index].should == 'user'
        csv_data[1][index+1].should == 'UNICEF'
      end

      it "should not have updated_by info for child that was not edited" do
        csv_data = FasterCSV.parse subject.data
        csv_data[1][7].should == ''
      end

    end
    
    describe "with a multi checkbox field" do
      subject do
        FormSection.stub!(:all_visible_child_fields).and_return [Field.new_check_boxes_field("multi")]
        ExportGenerator.new( [
                              Child.new( 'multi' => ["Dogs", "Cats"], 'unique_identifier' => "xxxy" ),
                              Child.new( 'multi' => nil, 'unique_identifier' => "xxxy" ),
                              Child.new( 'multi' => ["Cats", "Fish"], 'unique_identifier' => "yyyx" )
                             ]).to_csv
      end
      
      it "should render multi checkbox fields as a comma separated list" do
        csv_data = FasterCSV.parse subject.data
        csv_data[1][2].should == "Dogs, Cats"
        csv_data[2][2].should == ""
        csv_data[3][2].should == "Cats, Fish"
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
