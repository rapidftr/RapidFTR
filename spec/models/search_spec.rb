require 'spec_helper'
describe Search, :solr => true do

  context 'Child Search specific, until Enquiry models have boolean properties' do
    describe 'marked_as' do
      before :each do
        Sunspot.remove_all!
      end

      context 'active' do
        before :each do
          @model1 = create :child
        end

        it 'should not include duplicate models' do
          create :child, :duplicate => true, :duplicate_of => @model1.id
          results = Search.for(Child).marked_as('active').results
          expect(results.count).to eq(1)
          expect(results.first).to eq(@model1)
        end

        it 'should not include reunited models' do
          create :child, :reunited => true
          results = Search.for(Child).marked_as('active').results
          expect(results.count).to eq(1)
          expect(results.first).to eq(@model1)
        end
      end

      context 'reunited' do
        before :each do
          @model1 = create :child, :reunited => true
          @model2 = create :child, :reunited => false
        end

        it 'should filter models by reunited' do
          results = Search.for(Child).marked_as('reunited').results
          expect(results.count).to eq(1)
          expect(results.first).to eq(@model1)
        end
      end
    end
  end

  shared_examples "search" do
    before :each do
      Sunspot.remove_all!
    end
    describe 'pagination' do

      it 'should return all results' do
        model = create model_factory
        expect(Search.for(model_class).results).to eq [model]
        # TODO: make sure no pagination variables
      end

      it 'should paginate models' do
        5.times do
          create model_factory
        end

        results = Search.for(model_class).paginated(2, 2).results
        expect(results.total_pages).to eq(3)
        expect(results.offset).to eq(2)

        expect(results.previous_page).to eq(1)
        expect(results.current_page).to eq(2)
        expect(results.next_page).to eq(3)
      end
    end

    describe 'order results' do
      before :each do
        @model1 = create model_factory, :created_by => 'Test 1', :last_updated_at => 1.minute.ago.to_s
        @model2 = create model_factory, :created_by => 'Test 2', :last_updated_at => 1.hour.ago.to_s
        @model3 = create model_factory, :created_by => 'Test 3', :last_updated_at => 1.day.ago.to_s
        @model4 = create model_factory, :created_by => 'Test 4', :last_updated_at => 1.week.ago.to_s
      end

      it 'should order results ascending' do
        results = Search.for(model_class).ordered(:created_by, :asc).results
        expect(results).to eq [@model1, @model2, @model3, @model4]
      end

      # TODO: Test may fail randomly, need to troubleshoot if it happens next time
      it 'should order results descending' do
        results = Search.for(model_class).ordered(:created_by, :desc).results
        expect(results).to eq [@model4, @model3, @model2, @model1]
      end

      it 'should default to ascending' do
        results = Search.for(model_class).ordered(:created_by).results
        expect(results).to eq [@model1, @model2, @model3, @model4]
      end

      describe 'by time' do
        it 'should order ascending' do
          results = Search.for(model_class).ordered(:last_updated_at, :asc).results
          expect(results).to eq [@model4, @model3, @model2, @model1]
        end

        it 'should order descending' do
          results = Search.for(model_class).ordered(:last_updated_at, :desc).results
          expect(results).to eq [@model1, @model2, @model3, @model4]
        end
      end
    end

    describe 'empty results' do
      it 'should return an empty array' do
        expect(Search.for(model_class).results).to eq([])
      end
    end

    describe 'created_by' do
      before :each do
        @user1 = create :user
        @user2 = create :user
        @model1 = create model_factory, :created_by => @user1.user_name
        @model2 = create model_factory, :created_by => @user2.user_name
      end

      it 'should only return models created by the user' do
        results = Search.for(model_class).created_by(@user1).results
        expect(results.count).to eq(1)
        expect(results.first).to eq(@model1)
      end
    end

    describe 'fulltext' do

      it 'should return words with accented characters when searching for normal english words' do
        Sunspot.setup(model_class) do
          text :name
        end

        model1 = create model_factory, :name => 'Céçillé'
        model2 = create model_factory, :name => 'Cecille'

        results = Search.for(model_class).fulltext_by(['name'], 'Cecille').results

        expect(results.count).to eq(2)
        expect(results).to include(model1)
        expect(results).to include(model2)
      end

      it 'should return normal english words when searching for words with accented characters' do
        Sunspot.setup(model_class) do
          text :name
        end

        model1 = create model_factory, :name => 'Céçillé'
        model2 = create model_factory, :name => 'Cecille'

        results = Search.for(model_class).fulltext_by(['name'], 'Céçillé').results

        expect(results.count).to eq(2)
        expect(results).to include(model1)
        expect(results).to include(model2)
      end

    end

    describe 'less_than' do
    end

    describe 'greater_than' do
    end
  end

  describe 'ChildSearch' do
    it_behaves_like 'search' do
      let(:model_class) { Child }
      let(:model_factory) { :child }
    end
  end

  describe 'EnquirySearch' do
    it_behaves_like 'search' do
      let(:model_class) { Enquiry }
      let(:model_factory) { :enquiry }
    end
  end
end
