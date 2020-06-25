# frozen_string_literal: true

require 'acts_as_tracked/version'

require 'active_record'
require 'active_support'

require 'acts_as_tracked/activity'
require 'acts_as_tracked/extenders/trackable'

module ActsAsTracked
  ActiveRecord::Base.extend ActsAsTracked::Extenders::Trackable
end
