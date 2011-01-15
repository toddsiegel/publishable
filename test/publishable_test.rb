require 'test_helper'
require 'active_record'

#TODO: add publish method
#TODO: add unpublish method
#TODO: add published scope
#TODO: add draft scope
#TODO: add future_published scope
#TODO: add :column override

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.establish_connection(:adapter => "mysql",
                                        :username => "root",
                                        :password => "",
                                        :host => "localhost",
                                        :socket => "/tmp/mysql.sock",
                                        :database => "publishable_test")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :publishables do |t|
      t.column :published_at, :datetime
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
    publishable
  end

  def setup
    setup_db
    @draft = Publishable.create!
    @future_published = Publishable.create!(:published_at => 1.week.from_now)
    @published = Publishable.create!(:published_at => 1.week.ago)
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
  
end
