require "rails_helper"

describe Book do
  describe "relationships" do
    it "should have many readings" do
      t = User.reflect_on_association :readings
      expect(t.macro).to eq :has_many
      expect(t.options[:dependent]).to eq :destroy
    end

    it "should have many favorites" do
      t = User.reflect_on_association :favorites
      expect(t.macro).to eq :has_many
      expect(t.options[:dependent]).to eq :destroy
    end
  end

  describe "validation" do
    let(:book) { FactoryGirl.build :book }
    describe "title" do
      describe "when not present" do
        before { book.title = nil }
        it "should validate title is not present" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :title
          expect(book.errors.messages[:title]).to include "can't be blank"
        end
      end

      describe "when title length is less than minimum requires" do
        before do
          Settings.admin.books.min_title_length = 6
          book.title = Faker::Lorem.word[0..4]
        end
        it "should validate title is not present" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :title
          expect(book.errors.messages[:title]).to include I18n.t("admin.validate_title", min: Settings.admin.books.min_title_length)
        end
      end
    end

    describe "author" do
      describe "when #author is not present" do
        before { book.author = nil }
        it "should validate author is not present" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :author
          expect(book.errors.messages[:author]).to include "can't be blank"
        end
      end
    end

    describe "number_page" do
      describe "when #number_page is not present" do
        before { book.number_page = nil }
        it "should validate number_page is not present" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :number_page
          expect(book.errors.messages[:number_page]).to include "can't be blank"
        end
      end
      describe "when #number_page is not number" do
        before { book.number_page = "text" }
        it "should validate number_page is not text" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :number_page
          expect(book.errors.messages[:number_page]).to include "is not a number"
        end
      end
      describe "when #number_page is less or equal min_number_pag" do
        before do
          book.number_page = 1
        end
        it "should return number_page greater than" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :number_page
          expect(book.errors.messages[:number_page]).to include "must be greater than 1"
        end
      end
      describe "when #number_page is greater than max_number_page" do
        before do
          book.number_page = 50001
        end
        it "should return number_page less than or equal" do
          expect(book).not_to be_valid
          expect(book.errors.messages.keys).to include :number_page
          expect(book.errors.messages[:number_page]).to include "must be less than or equal to 50000"
        end
      end
    end
  end
  describe "scope" do
    let(:user) { FactoryGirl.create :user }
    let(:books) { FactoryGirl.create_list :book, 10 }
    let(:fav_books) { books[0..4] }
    let(:sug_books) { books[5..9] }
    before do
      fav_books.each do |book|
        user.favorites.create book: book
      end
    end
    describe "un_favorite" do
      it "should return list unfavorite books" do
        expect(Book.un_favorite(user)).to include *sug_books
      end
    end

    describe "suggest_un_favorite_books" do
      it "should return list suggest unfavorite books" do
        expect(Book.suggest_un_favorite_books(user)).to include *sug_books
      end
    end
  end

  describe "mount uploader" do
    it "should return picture file" do
      FactoryGirl.define do
        factory :picture do
          photo Rack::Test::UploadedFile
                  .new(File.open(File.join(Rails.root, "/spec/fixtures/myfile.jpg")))
        end
      end
    end
  end
end
