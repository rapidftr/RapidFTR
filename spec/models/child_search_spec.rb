require 'spec_helper'

describe ChildSearch, :solr => true do
  before :each do
    Sunspot.remove_all!
  end

  describe "pagination" do
    it "should return all children" do
      child = create :child
      expect(ChildSearch.new.results).to eq [child]
      # TODO: make sure no pagination variables
    end

    it "should paginate children" do
      5.times do
        create :child
      end

      results = ChildSearch.new.paginated(2, 2).results
      expect(results.total_pages).to eq(3)
      expect(results.offset).to eq(2)

      expect(results.previous_page).to eq(1)
      expect(results.current_page).to eq(2)
      expect(results.next_page).to eq(3)
    end
  end

  describe "order results" do
    before :each do
      @child1 = create :child, :created_by => "Test 1", :last_updated_at => 1.minute.ago.to_s
      @child2 = create :child, :created_by => "Test 2", :last_updated_at => 1.hour.ago.to_s
      @child3 = create :child, :created_by => "Test 3", :last_updated_at => 1.day.ago.to_s
      @child4 = create :child, :created_by => "Test 4", :last_updated_at => 1.week.ago.to_s
    end

    it "should order results ascending" do
      results = ChildSearch.new.ordered(:created_by, :asc).results
      expect(results).to eq [@child1, @child2, @child3, @child4]
    end

    # TODO: Test may fail randomly, need to troubleshoot if it happens next time
    it "should order results descending" do
      results = ChildSearch.new.ordered(:created_by, :desc).results
      expect(results).to eq [@child4, @child3, @child2, @child1]
    end

    it "should default to ascending" do
      results = ChildSearch.new.ordered(:created_by).results
      expect(results).to eq [@child1, @child2, @child3, @child4]
    end

    describe "by time" do
      it "should order ascending" do
        results = ChildSearch.new.ordered(:last_updated_at, :asc).results
        expect(results).to eq [@child4, @child3, @child2, @child1]
      end

      it "should order descending" do
        results = ChildSearch.new.ordered(:last_updated_at, :desc).results
        expect(results).to eq [@child1, @child2, @child3, @child4]
      end
    end
  end

  describe "empty results" do
    it "should return an empty array" do
      expect(ChildSearch.new.results).to eq([])
    end
  end

  describe "created_by" do
    before :each do
      @user1 = create :user
      @user2 = create :user
      @child1 = create :child, :created_by => @user1.user_name
      @child2 = create :child, :created_by => @user2.user_name
    end

    it "should only return children created by the user" do
      results = ChildSearch.new.created_by(@user1).results
      expect(results.count).to eq(1)
      expect(results.first).to eq(@child1)
    end
  end

  describe "marked_as" do
    context "active" do
      before :each do
        @child1 = create :child
      end

      it "should not include duplicate children" do
        create :child, :duplicate => true, :duplicate_of => @child1.id
        results = ChildSearch.new.marked_as('active').results
        expect(results.count).to eq(1)
        expect(results.first).to eq(@child1)
      end

      it "should not include reunited children" do
        create :child, :reunited => true
        results = ChildSearch.new.marked_as('active').results
        expect(results.count).to eq(1)
        expect(results.first).to eq(@child1)
      end
    end

    context "reunited" do
      before :each do
        @child1 = create :child, :reunited => true
        @child2 = create :child, :reunited => false
      end

      it "should filter children by reunited" do
        results = ChildSearch.new.marked_as('reunited').results
        expect(results.count).to eq(1)
        expect(results.first).to eq(@child1)
      end
    end
  end

  describe 'fulltext' do

    it 'should return words with accented characters when searching for normal english words' do
      Sunspot.setup(Child) do
        text :name
      end

      child1 = create :child, :name => "Céçillé"
      child2 = create :child, :name => "Cecille"

      results = ChildSearch.new.fulltext_by(["name"], "Cecille").results

      expect(results.count).to eq(2)
      expect(results).to include(child1)
      expect(results).to include(child2)
    end

    it 'should return normal english words when searching for words with accented characters' do
      Sunspot.setup(Child) do
        text :name
      end

      child1 = create :child, :name => "Céçillé"
      child2 = create :child, :name => "Cecille"

      results = ChildSearch.new.fulltext_by(["name"], "Céçillé").results

      expect(results.count).to eq(2)
      expect(results).to include(child1)
      expect(results).to include(child2)
    end

  end

  describe 'less_than' do
  end

  describe 'greater_than' do
  end
end
