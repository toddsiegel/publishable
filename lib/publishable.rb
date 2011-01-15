module Publishable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    #TODO: move named_scopes out of class_eval

    def publishable(options = {})
      configuration = { :column => "published_at"}
      configuration.update(options) if options.is_a?(Hash)


      class_eval <<-EOV
        include Publishable::InstanceMethods

        def column_name
          "#{configuration[:column]}"
        end
    
        named_scope :drafts,  lambda { { :conditions => ["#{configuration[:column]} IS NULL OR #{configuration[:column]} > ?", DateTime.now] } }
        named_scope :published,  lambda { { :conditions => ["#{configuration[:column]} <= ?", DateTime.now] } }
        
        def self.published_later
          drafts.find(:all, :conditions => ["#{configuration[:column]} IS NOT NULL"])
        end
      EOV
    end
  end
  
  module InstanceMethods

    def draft?
      !self.published?
    end
    
    def published?
      self[column_name].present? and self[column_name] <= DateTime.now
    end
    
    def publish(at = DateTime.now)
      change_state(at)
    end
    
    def unpublish
      change_state(nil)
    end

    private
      def change_state(val)
        send column_name + "=", val
        save
      end
  end
end
