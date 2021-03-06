require "test_helper"

describe Work do 
  before do 
    @album1 = works(:album1)
    @album2 = works(:album2)
    @album3 = works(:album3)
    @user1 = users(:user1)
    @user2 = users(:user2)
    @user3 = users(:user3)
  end

  describe "validations" do
    let (:new_album) {
      Work.new(
        category: "album",
        title: "new album title",
        creator: "new album creator",
        publication_year: 2020,
        description: "new album description"
      )
    }

    it "it is valid when all fields are present" do
      expect(@album1.valid?).must_equal true
    end

    it "will have the required fields" do
      [:category, :title, :creator, :publication_year, :description].each do |field|
        expect(@album1).must_respond_to field
      end
    end
    
    it "fails validation when there is a missing title" do
      new_album.title = nil

      expect(new_album.valid?).must_equal false
      expect(new_album.errors.messages.include?(:title)).must_equal true
      expect(new_album.errors.messages[:title].include?("can't be blank")).must_equal true
    end
    
    it "fails validation when there is a missing category" do
      new_album.category = nil

      expect(new_album.valid?).must_equal false
      expect(new_album.errors.messages.include?(:category)).must_equal true
      expect(new_album.errors.messages[:category].include?("can't be blank")).must_equal true
   end
 

   it "fails validation when there is a missing creator" do
      new_album.creator = nil

      expect(new_album.valid?).must_equal false
      expect(new_album.errors.messages.include?(:creator)).must_equal true
      expect(new_album.errors.messages[:creator].include?("can't be blank")).must_equal true
   end
 

   it "fails validation when there is a missing description" do
      new_album.description = nil

      expect(new_album.valid?).must_equal false
      expect(new_album.errors.messages.include?(:description)).must_equal true
      expect(new_album.errors.messages[:description].include?("can't be blank")).must_equal true
   end
 

   it "fails validation when there is a missing publication_year" do
      new_album.publication_year = nil

      expect(new_album.valid?).must_equal false
      expect(new_album.errors.messages.include?(:publication_year)).must_equal true
      expect(new_album.errors.messages[:publication_year].include?("can't be blank")).must_equal true
   end

   it "fails validation when a title already exists in the same category" do
    new_album.title = @album1.title

    expect(new_album.valid?).must_equal false
    expect(new_album.errors.messages.include?(:title)).must_equal true
    expect(new_album.errors.messages[:title].include?("has already been taken")).must_equal true
   end

   it "passes validation with same title but two different categories" do
      Work.create!(category: "book", title: new_album.title, creator: new_album.creator, publication_year: 2020, description: "new book same title as album")

      expect(new_album.valid?).must_equal true
      expect(new_album.errors.messages).must_be_empty
   end
  end

  describe "relations" do
    it "can have many votes" do
      expect(@album2.votes.count).must_equal 3
      @album2.votes.each do |vote|
        expect(vote).must_be_instance_of Vote
      end
    end
  end

  describe "custom methods" do
    describe "winner" do
      it "returns Work with most votes" do
        winner = works(:album2)
        expect(Work.winner).must_equal winner
        expect(Work.winner).must_be_instance_of Work
        expect(Work.winner.votes.length).must_equal 3
      end
    end

    describe "top ten" do
      before do
        @category = "album"
      end

      it "sorts by vote count if there are works in the database" do      
        expect(Work.top_ten(@category).first).must_equal @album2
        expect(Work.top_ten(@category).second).must_equal @album3
        expect(Work.top_ten(@category).third).must_equal @album1
      end

      it "only returns top 10 works in the category" do      
        expect(Work.top_ten(@category).count).must_equal 10
      end

      it "gets less than 10 works if less than 10 present" do
        Work.destroy_all
        Work.create!(category: "album", title: "lonely in the database", creator: "lonely", publication_year: 2020, description: "little ol me")

        expect(Work.top_ten(@category).count).must_equal 1
      end

      it "returns an empty array if category is empty" do
        Work.destroy_all
        top_albums = Work.top_ten(@category)

        expect(top_albums).must_be_instance_of Array
        expect(top_albums.size).must_equal 0
      end
    end
    
    describe "display_by_votes" do
      it "returns an array of works by vote count in DESC order" do
        most_votes = works(:album2)
        
        expect(Work.display_by_votes(:album).first).must_equal most_votes
        expect(Work.display_by_votes(:album).first.votes.count).must_equal 3
      end
    end
  end
end
  