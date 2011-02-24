require 'test_helper'
require 'active_record'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

#TODO: change to use sqlite :memory:
ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                         :database => ":memory:")

#Supress schema output
$stdout = StringIO.new

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :publishables do |t|
      t.column :pub_date, :datetime
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class PublishableTest < ActiveSupport::TestCase

  class Publishable < ActiveRecord::Base
    publishable :column => :pub_date
  end

  def setup
    setup_db
    @draft = Publishable.create!
    @drafts = []
    3.times { |i| @drafts<< Publishable.create! }

    @future_published = Publishable.create!(:pub_date => 1.week.from_now)
  
    @published = Publishable.create!(:pub_date => 1.week.ago)
    @publisheds = []
    3.times { |i| @publisheds<< Publishable.create!(:pub_date => 1.week.ago) }
  end

  def teardown
    teardown_db
  end

  def test_draft?
    assert @draft.draft?
  end
  
  def test_draft_not_publshed?
    assert !@draft.published?
  end
  
  def test_future_published_is_draft?
    assert @future_published.draft?
  end
  
  def test_future_published_is_not_published?
    assert !@future_published.published?
  end
  
  def test_publshed?
    assert @published.published?
  end
  
  def test_publish
    @draft.publish
    @draft.published?
  end
  
  def test_unpublish
    @published.unpublish
    @published.draft?
  end
  
  def test_future_publish
    @draft.publish(1.week.from_now)
    assert @draft.draft?
  end
  
  def test_drafts_scope
    assert_equal [@draft, @drafts[0], @drafts[1], @drafts[2]], Publishable.drafts
  end
  
  def test_published_scope
    assert_equal [@published, @publisheds[0], @publisheds[1], @publisheds[2]], Publishable.published
  end
  
  def test_future_published_scope
    assert_equal [@future_published], Publishable.published_later
  end
end
