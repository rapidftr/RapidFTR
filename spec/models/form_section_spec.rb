# -*- coding: utf-8 -*-
require 'spec_helper'

describe FormSection do

  def mock_formsection(stubs={})
    stubs.reverse_merge!(:fields=>[], :save => true, :editable => true)
    @mock_formsection ||= mock_model(FormSection, stubs)
  end

  def new_field(fields = {})
    fields.reverse_merge!(:name=>random_string)
    Field.new fields
  end

  def random_string(length=10)
    #hmmm
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    password = ''
    length.times { password << chars[rand(chars.size)] }
    password
  end

  def new_should_be_called_with (name, value)
    FormSection.should_receive(:new) { |form_section_hash|
      form_section_hash[name].should == value
    }
  end

  it "should return all the searchable fields" do
    text_field = Field.new(:name => "text_field", :type => Field::TEXT_FIELD)
    text_area = Field.new(:name => "text_area", :type => Field::TEXT_AREA)
    select_box = Field.new(:name => "select_box", :type => Field::SELECT_BOX)
    radio_button = Field.new(:name => "radio_button", :type => Field::RADIO_BUTTON)
    f = FormSection.new(:fields => [text_field, text_area, select_box, radio_button])
    f.all_searchable_fields.should == [text_field, text_area, select_box]
  end

  describe '#unique_id' do
    it "should be generated when not provided" do
      f = FormSection.new
      f.unique_id.should_not be_empty
    end

    it "should not be generated when provided" do
      f = FormSection.new :unique_id => 'test_form'
      f.unique_id.should == 'test_form'
    end

    it "should not allow duplicate unique ids" do
      FormSection.new(:unique_id => "test", :name => "test").save!

      expect {
        FormSection.new(:unique_id => "test").save!
      }.to raise_error

      expect {
        FormSection.get_by_unique_id("test").save!
      }.to_not raise_error
    end
  end

  describe "repository methods" do
    before { FormSection.all.each &:destroy }

    describe "enabled_by_order" do
      it "should bring back sections in order" do
        second = FormSection.create! :name => 'Second', :order => 2, :unique_id => 'second'
        first = FormSection.create! :name => 'First', :order => 1, :unique_id => 'first'
        third = FormSection.create! :name => 'Third', :order => 3, :unique_id => 'third'
        FormSection.enabled_by_order.map(&:name).should == %w( First Second Third )
      end

      it "should exclude disabled sections" do
        expected = FormSection.create! :name => 'Good', :order => 1, :unique_id => 'good'
        unwanted = FormSection.create! :name => 'Bad', :order => 2, :unique_id => 'bad', :visible => false
        FormSection.enabled_by_order.map(&:name).should == %w(Good)
        FormSection.enabled_by_order.map(&:name).should_not ==  %w(Bad)
      end
    end

    describe "enabled_by_order_without_hidden_fields" do
      it "should exclude hidden fields" do
        visible_field = Field.new(:name => "visible_field", :display_name => "Visible Field", :visible => true)
        hidden_field = Field.new(:name => "hidden_field", :display_name => "Hidden Field", :visible => false)

        section = FormSection.new :name => 'section', :order => 1, :unique_id => 'section'
        section.fields = [visible_field, hidden_field]
        section.save!

        form_section = FormSection.enabled_by_order_without_hidden_fields.first
        form_section.fields.should == [visible_field]
      end
    end
  end

  describe "get_by_unique_id" do
    it "should retrieve formsection by unique id" do
      expected = FormSection.new
      unique_id = "fred"
      FormSection.stub(:by_unique_id).with(:key=>unique_id).and_return([expected])
      FormSection.get_by_unique_id(unique_id).should == expected
    end

    it "should save fields" do
      section = FormSection.new :name => 'somename', :unique_id => "someform"
      section.save!

      section.fields = [Field.new(:name => "a field", :type => "text_field", :display_name => "A Field")]
      section.save!

      field = section.fields.first
      field.name = "kev"
      section.save!

      section = FormSection.get_by_unique_id("someform")
      section.name.should == 'somename'
    end

  end

  describe "add_field_to_formsection" do

    it "adds the field to the formsection" do
      field = Field.new_text_field("name")
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection" do
      field = Field.new_text_field("name")
      formsection = mock_formsection
      formsection.should_receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

    it "should raise an error if adding a field to a non editable form section" do
      field = new_field :name=>'field_one'
      formsection = FormSection.new :editable => false
      lambda { FormSection.add_field_to_formsection formsection, field }.should raise_error
    end

  end


  describe "add_textarea_field_to_formsection" do

    it "adds the textarea to the formsection" do
      field = Field.new_textarea("name")
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection with textarea field" do
      field = Field.new_textarea("name")
      formsection = mock_formsection
      formsection.should_receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

  end

  describe "add_select_drop_down_field_to_formsection" do

    it "adds the select drop down to the formsection" do
      field = Field.new_select_box("name", ["some", ""])
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection with select drop down field" do
      field = Field.new_select_box("name", ["some", ""])
      formsection = mock_formsection
      formsection.should_receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

  end

  describe "editable" do

    it "should be editable by default" do
      formsection = FormSection.new
      formsection.editable?.should be_true
    end

  end

  describe "perm_visible" do
    it "should not be perm_enabled by default" do
      formsection = FormSection.new
      formsection.perm_visible?.should be_false
    end

    it "should be perm_visible when set" do
      formsection = FormSection.new(:perm_visible => true)
      formsection.perm_visible?.should be_true
    end
  end

  describe "fixed_order" do
    it "should not be fixed)order by default" do
      formsection = FormSection.new
      formsection.fixed_order?.should be_false
    end

    it "should be fixed_order when set" do
      formsection = FormSection.new(:fixed_order => true)
      formsection.fixed_order?.should be_true
    end
  end

  describe "perm_enabled" do
    it "should not be perm_enabled by default" do
      formsection = FormSection.new
      formsection.perm_enabled?.should be_false
    end

    it "should be perm_enabled when set" do
      formsection = FormSection.create!(:name => "test", :uniq_id => "test_id", :perm_enabled => true)
      formsection.perm_enabled?.should be_true
      formsection.perm_visible?.should be_true
      formsection.fixed_order?.should be_true
      formsection.visible?.should be_true
    end
  end

  describe "delete_field" do
    it "should delete editable fields" do
      @field = new_field(:name=>"field3")
      form_section = FormSection.new :fields=>[@field]
      form_section.delete_field(@field.name)
      form_section.fields.should be_empty
    end

    it "should not delete uneditable fields" do
      @field = new_field(:name=>"field3", :editable => false)
      form_section = FormSection.new :fields=>[@field]
      lambda {form_section.delete_field(@field.name)}.should raise_error("Uneditable field cannot be deleted")
    end
  end

  describe "save fields in given order" do
    it "should save the fields in the given field name order" do
      @field_1 = new_field(:name => "orderfield1", :display_name => "orderfield1")
      @field_2 = new_field(:name => "orderfield2", :display_name => "orderfield2")
      @field_3 = new_field(:name => "orderfield3", :display_name => "orderfield3")
      form_section = FormSection.create! :name => "some_name", :fields => [@field_1, @field_2, @field_3]
      form_section.order_fields([@field_2.name, @field_3.name, @field_1.name])
      form_section.fields.should == [@field_2, @field_3, @field_1]
      form_section.fields.first.should == @field_2
      form_section.fields.last.should == @field_1
    end
  end

  describe "new_with_order" do
    before :each do
      FormSection.stub(:all).and_return([])
    end
    it "should create a new form section" do
      FormSection.should_receive(:new).any_number_of_times
      FormSection.new_with_order({:name => "basic"})
    end

    it "should set the order to one plus maximum order value" do
      FormSection.stub(:by_order).and_return([FormSection.new(:order=>20), FormSection.new(:order=>10), FormSection.new(:order=>40)])
      new_should_be_called_with :order, 41
      FormSection.new_with_order({:name => "basic"})
    end
  end

  describe "valid?" do
    it "should validate name is filled in" do
      form_section = FormSection.new()
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
    end

    it "should not allows empty form names in form base_language " do
     form_section = FormSection.new(:name_en => 'English', :name_zh=>'Chinese')
     I18n.default_locale='zh'
     expect {
       form_section[:name_en]=''
       form_section.save!
     }.to raise_error
    end

    it "should validate name is alpha_num" do
      form_section = FormSection.new(:name=> "r@ndom name!")
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
    end

    it "should not allow name with white speces only" do
      form_section = FormSection.new(:name=> "     ")
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
    end

    it "should allow arabic names" do
      form_section = FormSection.new(:name=>"العربية")
      form_section.should be_valid
      form_section.errors.on(:name).should_not be_present
    end

    it "should validate name is unique" do
      same_name = 'Same Name'
      valid_attributes = {:name => same_name, :unique_id => same_name.dehumanize, :description => '', :visible => true, :order => 0}
      FormSection.create! valid_attributes.dup
      form_section = FormSection.new valid_attributes.dup
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
      form_section.errors.on(:unique_id).should be_present
    end

    it "should not occur error  about the name is not unique  when the name is not filled in" do
      form_section = FormSection.new(:name=>"")
      form_section.should_not be_valid
      form_section.errors.on(:unique_id).should_not be_present
    end

    it "should not trip the unique name validation on self" do
      form_section = FormSection.new(:name => 'Unique Name', :unique_id => 'unique_name')
      form_section.create!
    end
  end

  describe "highlighted_fields" do
    describe "get highlighted fields" do
      before :each do
        high_attr = [{ :order => "1", :highlighted => true }, { :order => "2", :highlighted => true }, { :order => "10", :highlighted => true }]
        @high_fields = [ Field.new(:name => "h1", :highlight_information => high_attr[0]),
                         Field.new(:name => "h2", :highlight_information => high_attr[1]),
                         Field.new(:name => "h3", :highlight_information => high_attr[2]) ]
        field = Field.new :name => "regular_field"
        form_section1 = FormSection.new( :name => "Highlight Form1", :fields => [@high_fields[0], @high_fields[2], field] )
        form_section2 = FormSection.new( :name => "Highlight Form2", :fields => [@high_fields[1]] )
        FormSection.stub(:all).and_return([form_section1, form_section2])
      end

      it "should get fields that have highlight information" do
        highlighted_fields = FormSection.highlighted_fields
        highlighted_fields.size.should == @high_fields.size
        highlighted_fields.map do |field| field.highlight_information end.should
          include @high_fields.map do |field| field.highlight_information end
      end

      it "should sort the highlighted fields by highlight order" do
        sorted_highlighted_fields = FormSection.sorted_highlighted_fields
        sorted_highlighted_fields.map do |field| field.highlight_information.order end.should ==
          @high_fields.map do |field| field.highlight_information.order end
      end
    end

    describe "highlighted fields" do

      it "should update field as highlighted" do
        attrs = { :field_name => "h1", :form_id => "highlight_form" }
        existing_field = Field.new :name => attrs[:field_name]
        form = FormSection.new(:name => "Some Form",
                               :unique_id => attrs[:form_id],
                               :fields => [existing_field])
        FormSection.stub(:all).and_return([form])
        form.update_field_as_highlighted attrs[:field_name]
        existing_field.highlight_information.order.should == 1
        existing_field.is_highlighted?.should be_true
      end

      it "should increment order of the field to be highlighted" do
        attrs = { :field_name => "existing_field", :form_id => "highlight_form"}
        existing_field = Field.new :name => attrs[:field_name]
        existing_highlighted_field = Field.new :name => "highlighted_field"
        existing_highlighted_field.highlight_with_order 3
        form = FormSection.new(:name => "Some Form",
                               :unique_id => attrs[:form_id],
                               :fields => [existing_field, existing_highlighted_field])
        FormSection.stub(:all).and_return([form])
        form.update_field_as_highlighted attrs[:field_name]
        existing_field.is_highlighted?.should be_true
        existing_field.highlight_information.order.should == 4
      end

      it "should un-highlight a field" do
        existing_highlighted_field = Field.new :name => "highlighted_field"
        existing_highlighted_field.highlight_with_order 1
        form = FormSection.new(:name => "Some Form", :unique_id => "form_id",
                               :fields => [existing_highlighted_field])
        FormSection.stub(:all).and_return([form])
        form.remove_field_as_highlighted existing_highlighted_field.name
        existing_highlighted_field.is_highlighted?.should be_false
      end
    end

    describe "formatted hash" do
      it "should combine the translations into a hash" do
        fs = FormSection.new(:name_en => "english name", :name_fr => "french name", :unique_id => "unique id",
                             :fields => [Field.new(:display_name_en => "dn in english", :display_name_zh => "dn in chinese", :name => "name")])
        form_section = fs.formatted_hash
        form_section["name"].should == {"en" => "english name", "fr" => "french name"}
        form_section["unique_id"].should == "unique id"
        form_section["fields"].first["display_name"].should == {"en" => "dn in english", "zh" => "dn in chinese"}
        form_section["fields"].first["name"].should == "name"
      end
    end
  end
end
