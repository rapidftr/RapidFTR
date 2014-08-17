require 'spec_helper'

describe AdvancedSearchHelper, :type => :helper do
  it "should generate the appropriate html for given text field criteria" do
    field = Field.new(:name => "name", :display_name => "Name", :type => Field::TEXT_FIELD)
    criteria = {:join => "", :display_name => "Name", :index => "0", :field => "name", :value => "test"}
    expect(helper.generate_html(criteria, [field]).gsub("\n", '')).to eq(%(<p class='criterion-selected'><a class="select-criteria">Name</a>
<input class="criteria-field" type="hidden" value="name" name="criteria_list[0][field]">
<input class="criteria-index" type="hidden" value="0" name="criteria_list[0][index]">
<span class=\"criteria-values\"/>
<input class="criteria-value-text" type="text" value="test" name="criteria_list[0][value]" style=""><a class=\"remove-criteria\">remove</a></p>).gsub("\n", ''))
  end

  it "should generate the appropriate html for given select box criteria" do
    field = Field.new(:name => "protection_status", :display_name => "Protection Status", :type => Field::SELECT_BOX, :option_strings_text => "\nUnaccompanied\nSeparated")
    criteria = {:join => "AND", :display_name => "Protection Status", :index => "1", :field => "protection_status", :value => "Separated"}
    expect(helper.generate_html(criteria, [field]).gsub("\n", '')).to eq(%(<p class='criterion-selected'>
<input id="criteria_join_and" type="radio" value="AND" checked='' name="criteria_list[1][join]">
<label for="criteria_join_and">And</label>
<input id="criteria_join_or" type="radio" value="OR"  name="criteria_list[1][join]">
<label for="criteria_join_or">Or</label>
<a class="select-criteria">Protection Status</a>
<input class="criteria-field" type="hidden" value="protection_status" name="criteria_list[1][field]">
<input class="criteria-index" type="hidden" value="1" name="criteria_list[1][index]">
<span class=\"criteria-values\"/>
<select class="criteria-value-select" value="" name="criteria_list[1][value]" style="">
<option  value=""></option>
<option  value="Unaccompanied">Unaccompanied</option>
<option selected="selected" value="Separated">Separated</option>
</select>
<a class="remove-criteria">remove</a>
</p>).gsub("\n", ""))
  end

  it "should return '' string if criteria's field is not found'" do
    expect(helper.generate_html({:name => "some_name", :field => "some_field"}, [])).to eq("")
  end
end
