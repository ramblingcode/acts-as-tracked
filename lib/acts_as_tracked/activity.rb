# frozen_string_literal: true

module ActsAsTracked
  class Activity < ActiveRecord::Base
    belongs_to :actor, polymorphic: true
    belongs_to :subject, polymorphic: true
    belongs_to :parent, polymorphic: true

    before_save { self[:attribute_changes] = self[:attribute_changes].with_indifferent_access }

    store :attribute_changes

    validates :subject, :actor, :activity_type, presence: true

    default_scope -> { order(arel_table[:created_at].desc) }

    def human_changes
      case activity_type
      when 'created'
        attribute_changes.reject { |_, values| values.last.to_s.blank? }
      when 'updated'
        attribute_changes.each { |_, values| values.map! { |v| v.presence || 'empty' } }
      when 'destroyed'
        attribute_changes.reject { |_, values| values.first.to_s.blank? }
      end
    end

    def subject_class
      @subject_class ||= subject_type&.constantize
    end

    def parent_class
      @parent_class ||= parent_type&.constantize
    end
  end
end
