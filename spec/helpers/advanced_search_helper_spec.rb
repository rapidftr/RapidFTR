require 'spec_helper'

describe AdvancedSearchHelper do
  it "should generate the appropriate html for given text field criteria" do
    field = Field.new(:name => "name", :display_name => "Name", :type => Field::TEXT_FIELD)
    criteria = SearchCriteria.new({:join => "", :display_name => "Name", :index => "0", :field => "name", :value => "test"})
    helper.generate_html(criteria, [field]).gsub("\n", '').should == %Q{<p><a class="select-criteria">Name</a>
<input class="criteria-field" type="hidden" value="name" name="criteria_list[0][field]">
<input class="criteria-index" type="hidden" value="0" name="criteria_list[0][index]">
<input class="criteria-value-text" type="text" value="test" name="criteria_list[0][value]" style=""></p>}.gsub("\n", '')
  end

  it "should generate the appropriate html for given select box criteria" do
    field = Field.new(:name => "protection_status", :display_name => "Protection Status", :type => Field::SELECT_BOX, :option_strings => ["", "Unaccompanied", "Separated"])
    criteria = SearchCriteria.new({:join => "AND", :display_name => "Protection Status", :index => "1", :field => "protection_status", :value => "Separated"})
    helper.generate_html(criteria, [field]).gsub("\n", '').should == %Q{<p>
<input id="criteria_join_and" type="radio" value="AND" checked='' name="criteria_list[1][join]">
<label for="criteria_join_and">And</label>
<input id="criteria_join_or" type="radio" value="OR"  name="criteria_list[1][join]">
<label for="criteria_join_or">Or</label>
<a class="select-criteria">Protection Status</a>
<input class="criteria-field" type="hidden" value="protection_status" name="criteria_list[1][field]">
<input class="criteria-index" type="hidden" value="1" name="criteria_list[1][index]">
<select class="criteria-value-select" value="" name="criteria_list[1][value]" style="">
<option  value=""></option>
<option  value="Unaccompanied">Unaccompanied</option>
<option selected="selected" value="Separated">Separated</option>
</select>
<a class="remove-criteria">remove</a>
</p>}.gsub("\n", "")
  end

  it "should return '' string if criteria's display_name is empty" do
    helper.generate_html(SearchCriteria.new(:name => "some_name", :field => "some_field", :display_name => ""), []).should == ""
  end
end
