require 'rubygems'
require 'sunspot' # In the real world we should probably vendor this.
require 'spec_helper'

describe "Solar" do
  
  class ChildInstanceAccessor < Sunspot::Adapters::InstanceAdapter
    
    def id
      @instance.id
    end
  end
  
  class ChildDataAccessor < Sunspot::Adapters::DataAccessor 
    def load(id)
      Child.get(id)
    end
  end
  
  Sunspot::Adapters::DataAccessor.register(ChildDataAccessor, Child)
  Sunspot::Adapters::InstanceAdapter.register(ChildInstanceAccessor, Child)
  
  Sunspot.setup(Child) do
    text :name
    string :name
  end
  
  def search_with_string(input)
    input = input.downcase
    Sunspot.search(Child) do 
      fulltext("name_text:#{input}* OR name_text:#{input}~0.01")
      adjust_solr_params do |params| 
        params[:defType] = "lucene"
      end 
    end
  end

  it "should match on the first part of a child's first name" do
    Sunspot.remove_all(Child)
    child1 = Child.create('last_known_location' => "New York", "name" => "Mohammed Smith")
    child2 = Child.create('last_known_location' => "New York", "name" => "Muhammed Jones")
    child3 = Child.create('last_known_location' => "New York", "name" => "Muhammad Brown")
    child4 = Child.create('last_known_location' => "New York", "name" => "Ammad Brown")
    Sunspot.index([child1, child2, child3, child4])
    Sunspot.commit    
    
    search = search_with_string("Muha")
    
    search.results.map(&:name).sort.should == ["Muhammad Brown", "Muhammed Jones"]
  end

  it "should match on the first part of a child's last name" do
    Sunspot.remove_all(Child)
    child1 = Child.create('last_known_location' => "New York", "name" => "Mohammed Smith")
    child2 = Child.create('last_known_location' => "New York", "name" => "Muhammed Jones")
    child3 = Child.create('last_known_location' => "New York", "name" => "Muhammad Brown")
    child4 = Child.create('last_known_location' => "New York", "name" => "Ammad Brown")
    Sunspot.index([child1, child2, child3, child4])
    Sunspot.commit    
    
    search = search_with_string("Bro")
    
    search.results.map(&:name).sort.should == ["Ammad Brown", "Muhammad Brown"]
  end

  it "should match on approximate spelling of a child's entire first name" do
    Sunspot.remove_all(Child)
    child1 = Child.create('last_known_location' => "New York", "name" => "Mohammed Smith")
    child2 = Child.create('last_known_location' => "New York", "name" => "Muhammed Jones")
    child3 = Child.create('last_known_location' => "New York", "name" => "Muhammad Brown")
    child4 = Child.create('last_known_location' => "New York", "name" => "Ammad Brown")
    Sunspot.index([child1, child2, child3, child4])
    Sunspot.commit    
    
    search = search_with_string("Mohamed")
    
    search.results.map(&:name).sort.should == ["Mohammed Smith", "Muhammad Brown", "Muhammed Jones"]
  end

  it "should support partial reindexing" do
    Sunspot.remove_all(Child)
    child1 = Child.create('last_known_location' => "New York", "name" => "Mohammed Smith")
    child2 = Child.create('last_known_location' => "New York", "name" => "Muhammed Jones")
    child3 = Child.create('last_known_location' => "New York", "name" => "Muhammad Brown")
    child4 = Child.create('last_known_location' => "New York", "name" => "Ammad Brown")
    Sunspot.index([child1, child2])
    Sunspot.commit    
    
    Sunspot.index([child3, child4])
    Sunspot.commit    

    search = search_with_string("Mohamed")
    
    search.results.map(&:name).sort.should == ["Mohammed Smith", "Muhammad Brown", "Muhammed Jones"]
  end
  
  it "should load child instance" do
    child = Child.create('last_known_location' => "New York")
    
    accessor = ChildInstanceAccessor.new child
    accessor.id.should == child.id
  end
  
  it "should load_all child instances" do
    child = Child.create('last_known_location' => "New York")
    
    accessor = ChildDataAccessor.new Child
    accessor.load(child.id).should == child
  end
  
end
