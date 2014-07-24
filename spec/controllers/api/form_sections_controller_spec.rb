require 'spec_helper'

describe Api::FormSectionsController, :type => :controller do

  before :each do
    fake_admin_login
  end

  describe "index" do
    before :each do
      reset_couchdb!

      @form1 = create :form
      @form2 = create :form
      @form_section1 = create :form_section, order: 10, form: @form1
      @form_section2 = create :form_section, visible: false, form: @form1
      @form_section3 = create :form_section, order: 1, form: @form1
      @form_section4 = create :form_section, order: 1, form: @form2

      get :index, format: :json
      @json = JSON.parse response.body
    end

    it "should return visible form sections" do
      expect(@json[@form1.name].size).to eq(2)
    end

    it "should return by order" do
      expect(@json[@form1.name][0]["name"]["en"]).to eq(@form_section3.name_en)
      expect(@json[@form1.name][1]["name"]["en"]).to eq(@form_section1.name_en)
    end

    it "should return sections grouped by form" do
      expect(@json[@form1.name].size).to be(2)
      expect(@json[@form2.name].size).to be(1)
    end
  end
end