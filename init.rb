$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'publishable'
ActiveRecord::Base.class_eval { include Publishable }
