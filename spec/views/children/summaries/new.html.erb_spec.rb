require 'spec_helper'

describe "children/summaries/new.html.erb" do
  it "renders all field with the prefix search_params" do
    render
    response.should have_selector("form") do |form|
      form.should have_selector("input[name]") do |inputs|
        inputs.each do |input|
          input[:name].should match(/\[search_params\]/) unless input[:type] == "submit"
        end
      end
    end
  end

  it "should render a text box for searching on name" do
    render
    response.should have_selector("input[name='[search_params][name]']")
  end

  it "should have a form that posts to /children/summary/" do
    render
    response.should have_selector("form", :action =>"/children/summary", :method => "post")
  end
end