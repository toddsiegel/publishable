module Publishable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    #TODO: move named_scopes out of class_eval
    def publishable
      class_eval <<-EOV
        include Publishable::InstanceMethods
        named_scope :drafts,  lambda { { :conditions => ["published_at IS NULL OR published_at > ?", DateTime.now] } }
        named_scope :published,  lambda { { :conditions => ["published_at <= ?", DateTime.now] } }
      EOV
      
      def published_later
        drafts.find(:all, :conditions => ["published_at IS NOT NULL"])
      end
    end
  end
  
  module InstanceMethods
    def draft?
      !self.published?
    end
    
    def published?
      self.published_at.present? and self.published_at <= DateTime.now
    end
    
    def publish(at = DateTime.now)
      update_attribute(:published_at, at)
    end
    
    def unpublish
      update_attribute(:published_at, nil)
    end
    
  end
end
