module Publishable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def publishable(options = {})
      @@configuration = { :column => "published_at"}
      @@configuration.update(options) if options.is_a?(Hash)


      class_eval <<-EOV
        include Publishable::InstanceMethods

        def column_name
          "#{@@configuration[:column]}"
        end
        
      EOV

      named_scope :drafts,  lambda { { :conditions => { @@configuration[:column].to_sym => nil } } }
      named_scope :published,  lambda { { :conditions => ["#{@@configuration[:column]} <= ?", DateTime.now] } }

      def published_later
        self.find(:all, :conditions => ["#{@@configuration[:column]} > ?", DateTime.now])
      end
      
      def publish(ids)
        update_all("#{@@configuration[:column]} = '#{DateTime.now.strftime('%Y-%m-%d %H:00:00')}'", ["id IN (#{ids.join(',')})"])
      end

      def unpublish(ids)
        update_all("#{@@configuration[:column]} = NULL", ["id IN (#{ids.join(',')})"])
      end
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
