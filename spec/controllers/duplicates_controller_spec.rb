require 'spec_helper'

describe DuplicatesController, :type => :controller do
  include FakeLogin

  describe "GET new" do
    context "An admin user with a valid non-duplicate child id" do
      before :each do
        fake_admin_login

        @child = create :child, :name => "John", :unique_identifier => "1234", :created_by => controller.current_user_name
        @form_sections = [ mock_model(FormSection), mock_model(FormSection), mock_model(FormSection) ]

        get :new, :child_id => @child.id
      end

      it "should be successful" do
        expect(response).to be_success
      end

      it "should fetch and assign the child" do
        expect(assigns[:child]).to eq(@child)
      end

      it "should assign the page name" do
        expect(assigns[:page_name]).to eq("Mark 1234 as Duplicate")
      end
    end

    context "An non-admin user" do
      before :each do
        fake_login
        get :new, :child_id => "1234"
      end

      it "should get forbidden response" do
        expect(response.response_code).to eq(403)
      end
    end

    context "An admin user with a non-valid child id" do
      it "should redirect to flagged children page" do
        fake_admin_login
        get :new, :child_id => "not_a_valid_child_id"
        expect(response).to be_forbidden
      end
    end
  end

  describe "POST create" do
    context "An admin user with a valid non-duplicate child id" do
      before :each do
        fake_admin_login
        @child = Child.new
        allow(@child).to receive(:save)
      end

      it "should mark the child as duplicate" do
        fake_admin_login

        allow(Child).to receive(:get).with("1234").and_return(@child)

        expect(@child).to receive(:mark_as_duplicate).with("5678")

        post :create, :child_id => "1234", :parent_id => "5678"
      end

      it "should redirect to the duplicated child view" do

        allow(Child).to receive(:get).and_return(@child)
        allow(@child).to receive(:mark_as_duplicate)
        allow(@child).to receive(:save).and_return(true)

        post :create, :child_id => "1234", :parent_id => "5678"

        expect(response.response_code).to eq(302)
      end
    end
  end
end
