# frozen_string_literal: true

require 'acts_as_tracked/version'
require 'acts_as_tracked/extenders/trackable'
require 'acts_as_tracked/activity'

require 'active_record'

module ActsAsTracked
  ActiveRecord::Base.extend ActsAsTracked::Extenders::Trackable
end
