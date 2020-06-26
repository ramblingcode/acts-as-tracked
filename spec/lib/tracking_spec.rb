# frozen_string_literal: true

require 'spec_helper'
require 'acts_as_tracked/tracking'

RSpec.describe ActsAsTracked::Tracking do
  with_model :Actor do
    table do |t|
      t.text :name
      t.timestamps
    end
  end

  with_model :Klass do
    table do |t|
      t.text :name
      t.text :foo
      t.text :description
      t.timestamps
    end

    model do
      include ActsAsTracked::Tracking
    end
  end

  with_model :SecondKlass do
    table do |t|
      t.text :name
      t.timestamps
    end

    model do
      include ActsAsTracked::Tracking
    end
  end

  let(:actor) do
    Actor.create!(name: 'Actor')
  end

  it 'tracks activity on create' do
    a = Klass.new(name: 'Tom')

    expect do
      a.tracking_changes(actor: actor) { a.save! }
    end.to change(ActsAsTracked::Activity, :count).from(0).to(1)

    ActsAsTracked::Activity.last.tap do |activity|
      expect(activity.subject).to eq a
      expect(activity.actor).to eq actor
      expect(activity.activity_type).to eq 'created'
      expect(activity.attribute_changes).to eq('id' => ['', 1], 'name' => ['', 'Tom'])
    end
  end

  it 'tracks activity on update' do
    a = Klass.create!(name: 'Tom')

    expect do
      a.tracking_changes(actor: actor) { a.update!(name: 'Cucota') }
    end.to change(ActsAsTracked::Activity, :count).from(0).to(1)

    ActsAsTracked::Activity.last.tap do |activity|
      expect(activity.subject).to eq a
      expect(activity.actor).to eq actor
      expect(activity.activity_type).to eq 'updated'
      expect(activity.attribute_changes).to eq('name' => %w[Tom Cucota])
    end
  end

  it 'tracks activity on deletion' do
    a = Klass.create!(name: 'Tom')
    id = a.id

    expect do
      a.tracking_changes(actor: actor) { a.destroy! }
    end.to change(ActsAsTracked::Activity, :count).from(0).to(1)

    ActsAsTracked::Activity.last.tap do |activity|
      expect(activity.subject).to eq nil
      expect(activity.subject_id).to eq id
      expect(activity.actor).to eq actor
      expect(activity.activity_type).to eq 'destroyed'
      expect(activity.attribute_changes).to eq({})
    end
  end

  describe '.exclude_activity_attributes' do
    before do
      Klass.class_eval do
        exclude_activity_attributes :name, :description
      end
    end

    it 'allows do skip specific attributes from being tracked' do
      a = Klass.create!(name: 'Tom', foo: 'A')

      expect do
        a.tracking_changes(actor: actor) { a.update!(name: 'Cucota', foo: 'B') }
      end.to change(ActsAsTracked::Activity, :count).from(0).to(1)

      ActsAsTracked::Activity.last.tap do |activity|
        expect(activity.subject).to eq a
        expect(activity.actor).to eq actor
        expect(activity.activity_type).to eq 'updated'
        expect(activity.attribute_changes).to eq('foo' => %w[A B])
      end
    end
  end

  it 'can track changes from the class' do
    expect do
      Klass.tracking_changes(actor: actor) do
        Klass.create!(name: 'Tom')
      end
    end.to change(ActsAsTracked::Activity, :count).from(0).to(1)

    ActsAsTracked::Activity.last.tap do |activity|
      expect(activity.actor).to eq actor
      expect(activity.activity_type).to eq 'created'
      expect(activity.attribute_changes).to eq('id' => ['', 1], 'name' => ['', 'Tom'])
    end
  end

  describe '.activities_for' do
    it 'returns activities for the given ids' do
      a = nil

      expect do
        Klass.tracking_changes(actor: actor) do
          a = Klass.create!(name: 'Tom')
          a.update!(name: 'Jerry')
        end
      end.to change(ActsAsTracked::Activity, :count).from(0).to(2)

      expect(Klass.activities_for([a.id]).size).to eq 2
    end

    it 'includes results where the subject is the parent' do
      subject = nil

      expect do
        Klass.tracking_changes(actor: actor) do
          subject = Klass.create!(name: 'Tom')
          subject.update!(name: 'Jerry')
        end

        SecondKlass.tracking_changes(actor: actor, parent: subject) do
          SecondKlass.create! name: 'AAA'
        end
      end.to change(ActsAsTracked::Activity, :count).from(0).to(3)

      expect(Klass.activities_for([subject.id]).size).to eq 3
    end
  end
end
