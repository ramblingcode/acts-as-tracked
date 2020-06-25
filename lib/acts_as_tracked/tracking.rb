# frozen_string_literal: true

require 'active_support/concern'

module ActsAsTracked
  module Tracking
    extend ActiveSupport::Concern

    included do
      has_many :activities_as_subject, as: :subject, class_name: 'Activity', dependent: :nullify
      has_many :activities_as_parent, as: :parent, class_name: 'Activity', dependent: :nullify
      has_many :activities_as_actor, as: :actor, class_name: 'Activity', dependent: :nullify

      after_create :track_create_activity!, if: :tracking_changes?
      after_update :track_update_activity!, if: :tracking_changes?, prepend: true
      after_destroy :track_destroy_activity!, if: :tracking_changes?

      cattr_accessor(:__global_activity_attributes) { {} }
      cattr_accessor(:__global_tracking_changes) { false }
      cattr_accessor(:__excluded_attributes) { %w[updated_at created_at] }
    end

    def activities
      t = Activity.arel_table
      Activity.where t[:subject_type].eq(self.class.name).and(t[:subject_id].eq(id))
                                     .or(t[:parent_type].eq(self.class.name).and(t[:parent_id].eq(id)))
    end

    def tracking_changes(attributes)
      @activity_attributes = attributes
      @tracking_changes = true
      yield
    ensure
      @activity_attributes = {}
      @tracking_changes = false
    end

    def tracking_changes?
      @tracking_changes || self.class.__global_tracking_changes
    end

    def activity_attributes
      self.class.__global_activity_attributes.merge(@activity_attributes || {})
    end

    def activity_label
      raise NotImplementedError, "You must define this method in #{self.class}"
    end

    class_methods do
      def tracking_changes(opts)
        self.__global_activity_attributes = __global_activity_attributes.merge(opts)
        self.__global_tracking_changes = true
        yield
      ensure
        self.__global_activity_attributes = {}
        self.__global_tracking_changes = false
      end

      def exclude_activity_attributes(*attributes)
        self.__excluded_attributes += attributes.map(&:to_s)
      end

      def activities_for(ids)
        ids = Array.wrap(ids)
        t = Activity.arel_table
        Activity.where t[:subject_type].eq(name).and(t[:subject_id].in(ids))
                                       .or(t[:parent_type].eq(name).and(t[:parent_id].in(ids)))
      end
    end

    protected

    def track_activity!(type, defaults = {})
      Activity.create!(defaults.merge(subject: self, activity_type: type))
    end

    def track_create_activity!
      return true unless activity_changes.any?

      track_activity!(:created, activity_attributes.merge(attribute_changes: activity_changes))
      true
    end

    def track_update_activity!
      return true unless activity_changes.any?

      track_activity!(:updated, activity_attributes.merge(attribute_changes: activity_changes))
      true
    end

    def track_destroy_activity!
      track_activity!(:destroyed, activity_attributes)
      true
    end

    def activity_changes
      changes = saved_changes.transform_values(&:first).keys.reject do |x|
        self.class.__excluded_attributes.include?(x.to_s)
      end
      changes.map do |x|
        [x, [send("#{x}_before_last_save").to_s, self[x]]]
      end.to_h
    end
  end
end
