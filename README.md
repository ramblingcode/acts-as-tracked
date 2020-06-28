[![Gem Version](https://badge.fury.io/rb/acts-as-tracked.svg)](https://badge.fury.io/rb/acts-as-tracked)
[![CircleCI](https://circleci.com/gh/ramblingcode/acts-as-tracked.svg?style=svg)](https://circleci.com/gh/ramblingcode/acts-as-tracked)

# ActsAsTracked

Welcome to ActsAsTracked! This gem is an extension to your ActiveRecord models to track activities. It does not track everything all the time, but can be used wherever you find it necessary to have a history for changes alongside their actors.

There are few other gems such as [audited](https://github.com/collectiveidea/audited), however, it is tracking every change on your models. ActsAsTracked is controlled by `you` and will track changes only when `used directly`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_tracked'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install acts_as_tracked
```

## Usage

### Create Activities table

First, you would need to generate a migration to create Activities table in your database.

ActsAsTracked has extension to generate migrations. Please, run:

```shell
  bundle exec rails generate acts_as_tracked:migration
```

This will generate following migration:

```ruby
class ActsAsTrackedMigration < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :actor, polymorphic: true
      t.references :subject, polymorphic: true
      t.references :parent, polymorphic: true
      t.text :attribute_changes
      t.string :activity_type
      t.string :human_description
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :activity
  end
end
```

Run `bundle exec rails db:migrate` and let's move on to the usage.

### Call acts_as_tracked in your AR model

If you would like to track changes of `Post` model, you would need to call `acts_as_tracked` in it.

```ruby
  class Post < ApplicationRecord
    acts_as_tracked

    # You may optionally pass in exluded_activity_attributes
    # as an argument to not track given fields.
    #
    # acts_as_tracked(exclude_activity_attributes: %i[:api_key, :username])
  end
```

### Tracking Changes

Now, you are able to track changes on Post.

```ruby
@post = Post.first

Post.tracking_changes(actor: User.find(1)) do
  @post.update(
    content: 'New Content'
  )  
end
```

Let's try to get activities for Post we just changed:

```ruby
@post.activities

[
  #<ActsAsTracked::Activity:0x000056475df12840
  id: 1,
  actor_id: 1,
  actor_type: "User",
  subject_id: 2,
  subject_type: "Post",
  parent_id: nil,
  parent_type: nil,
  attribute_changes: {"content"=>["Great post content.", "New Content"]},
  activity_type: "updated",
  human_description: nil,
  created_at: Thu, 25 Jun 2020 12:03:39 UTC +00:00,
  updated_at: Thu, 25 Jun 2020 12:03:39 UTC +00:00>
]
```

## More features

You can check activities for the record in which it was an Actor:

```ruby
@post.activities_as_actor

...activities
```

You can check activities for the record in which it was a Subject:

```ruby
@post.activities_as_subject

...activities
```

You can check activities for collection of records by passing ids:

```ruby
Post.activities_for([post_id1, post_id2])

...activities
```

### Extra options to pass to `tracking_changes` call

`tracking_changes` method can accept 3 arguments:

1. actor: mandatory -> actor record
2. subject: optional -> acting on record, defaults to record you are changing
3. parent: optional -> parent record for acting on record, defaults to nil
4. human_description: optional -> description you would like to include on change, defaults to `nil`

```ruby
Post.tracking_changes(actor: User.first, subject: Post.first, human_description: 'Some description of change', parent: Post.first.parent) do
...your changes here
end
```

### Example application using ActsAsTracked

I have created a Rails 6 application with the usages of ActsAsTracked. Please refer to this [repo](https://github.com/ramblingcode/rails6-acts-as-tracked-usage)

## Credits

Initial work of ActsAsTracked has been done by @rogercampos and @camaloon team. I have refined, packaged, documented, added generators and published it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ramblingcode/acts-as-tracked. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/acts_as_tracked/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActsAsTracked project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/acts_as_tracked/blob/master/CODE_OF_CONDUCT.md).
