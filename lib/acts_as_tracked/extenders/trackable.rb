# frozen_string_literal: true

# require 'active_support/concern'

module ActsAsTracked
  module Extenders
    module Trackable
      # extend ActiveSupport::Concern

      # Includes Tracking module in specified model
      #
      # @params exclude_activity_attributes [:foo, :bar]
      # if given, excludes specified params from tracking

      def acts_as_tracked(args = {})
        require 'acts_as_tracked/tracking'

        include ::ActsAsTracked::Tracking

        exclude_activity_attributes(*args[:exclude_activity_attributes]) if args[:exclude_activity_attributes]
      end
    end
  end
end
