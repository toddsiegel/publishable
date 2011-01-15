module Publishable
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def publishable
      class_eval <<-EOV
        include Publishable::InstanceMethods
      EOV
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
