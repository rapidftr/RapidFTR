require 'spec_helper'

describe Api::FormSectionsController do

  before :each do
    fake_admin_login
  end

  describe "index" do
    before :each do
      reset_test_db!

      @form1 = create :form_section, order: 10
      @form2 = create :form_section, visible: false
      @form3 = create :form_section, order: 1

      get :index, format: :json
      @json = JSON.parse response.body
    end

    it "should return form sections" do
      expect(@json.size).to eq(2)
    end

    it "should return by order" do
      expect(@json[0]["name"]["en"]).to eq(@form3.name_en)
      expect(@json[1]["name"]["en"]).to eq(@form1.name_en)
    end
  end

end
