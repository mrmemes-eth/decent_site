# So you want more, eh?

## The `block` strategy

We've mentioned that the expose method takes a block before, but we haven't
discussed what it does with it yet. Let's rectify that.

Every call to `.expose` takes an optional `block`. If you pass a `block`, all
other arguments except for `name` are ignored.

Why might you want to use a block? Why, when you're not interacting with a
strictly-defined `resource`, per se, but still need to share something with
the view.

**Presenters**

There are other ways to crack this nut, but the `block` exposure is a handy
way to start. We'll assume that you're using [draper](draper) for the sake of
having a defined interface. A simple integration with draper might look like
this:

```ruby
class PeopleController < ApplicationController
  expose(:person)
  expose(:person_presenter) { person.decorate }
end
```

And there you have a memoized method that yields a decorated object and makes
it available to the view.

There are a myriad of reasons you might want to use the `block` form of
`decent_exposure`&hellip; and now you know you can.

## Strategies

Strategies let you define the way you interact with a resource in the most
granular way possible and they're actually what `decent_exposure` uses to
power itself.

There are only a couple of built-in strategies available, but it's good to
know about the options.

### `ActiveRecordWithEagerAttributesStrategy`

This is the default strategy that `decent_exposure` uses. If you don't specify
one, this is the one you're using. As the name implies, it is responsible for
eagerly assigning attributes to your `ActiveRecord` model instances.

### `ActiveRecordStrategy`

Sometimes you don't want the eager attribute assignment.
`ActiveRecordStrategy` lets you opt out of that, but still use the basic `ORM`
integration.

### Custom Strategies

For the times when custom behavior is needed to find a resource,
`decent_exposure` provides a base class you can extend. For example, if scoping
a resource from `current_user` is not an option, but you'd like to verify a
resource's relationship to the `current_user`, you can use a custom strategy
like the following:

```ruby
class VerifiableStrategy < DecentExposure::Strategy
  delegate :current_user, :to => :controller

  def resource
    instance = model.find(params[:id])
    if current_user != instance.user
      raise ActiveRecord::RecordNotFound
    end
    instance
  end
end
```

You can then use the custom strategy in your controller like so:

```ruby
expose(:post, strategy: VerifiableStrategy)
```

When subclassing DecentExposure::Strategy, the API only requires that you
define `resource`, but provides helpers to access some common things (e.g. the
`params` hash).  For everything else, you can delegate to controller, which is
the same as self in the context of a normal controller action.

### Class-Level Configuration

For most things, you'll be able to pass an option or two and get the
behavior you desire. For changes you want to affect every call to `expose` in a
controller or controllers inheriting from it (e.g. `ApplicationController`, if
you need to change the behavior for all your controllers), you can define a
`decent_configuration` block:

```ruby
class ApplicationController < ActionController::Base
  decent_configuration do
    strategy MongoidStrategy
  end
end
```

A `decent_configuration` block without a `:name` argument is considered the
"default" configuration for that controller (and it's ancestors). All things
considered, you probably only want to change the strategy in a default.
Nonetheless, you can pass any configuration option you can to an individual
exposure to the `decent_configuration` block.

If you don't want a specific configuration to affect every exposure in the
controller, you can give it a name like so:

```ruby
class ArticleController < ApplicationController
  decent_configuration(:sluggable) do
    finder :find_by_slug
    finder_parameter :slug
  end
end
```

And opt into it like so:

```ruby
expose(:article, config: :sluggable)
```

[draper]: https://github.com/drapergem/draper
