# frozen_string_literal: true

ActiveRecord::Schema.define do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'activities', force: :cascade do |t|
    t.integer 'actor_id'
    t.string 'actor_type'
    t.integer 'subject_id'
    t.string 'subject_type'
    t.integer 'parent_id'
    t.string 'parent_type'
    t.text 'attribute_changes'
    t.string 'activity_type'
    t.string 'human_description'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['actor_id'], name: 'index_activities_on_actor_id'
    t.index ['parent_id'], name: 'index_activities_on_parent_id'
    t.index ['subject_id'], name: 'index_activities_on_subject_id'
  end
end
