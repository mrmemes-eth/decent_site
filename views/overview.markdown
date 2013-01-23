# What is this thing?

Rails controllers are the sweaty armpit of every rails application. This is
due, in large part, to the fact that they expose their instance variables
directly to their views. This means that your instance variables are your
interface...  and that you've broken encapsulation. Instance variables are
meant to be private, for Science's sake!

`decent_exposure` proposes that you declare methods as an interface for your
view. It automatically makes those methods available to your views and
"memoizes" them so it's safe to call them multiple times without worrying
about reevaluating potentially expensive queries.

# Quick Start

Installation is super simple:

*In your Gemfile:*

    gem 'decent_exposure'

*In your console:*

    $ bundle

Really. That's it.

For notes on how to use `decent_exposure`, keep reading!

# Conventions

Rails loves conventions. So does `decent_exposure`! By following a few simple
conventions, you can have `decent_exposure` automate many repetitive tasks
controllers ask you to perform.

If you're using the default _strategies_ (more on that later),
`decent_exposure` assumes you're using `ActiveRecord` and that you want
your object's attributes to be automatically updated when creating or updating
a resource (a _resource_ here, is _an instance of an `ActiveRecord` object_).

## Fetching existing resources

This is the most commonly used convention, as we tend to spend much more time
interacting with resources than creating them. It looks like this:

    class Controller
      expose(:person)
    end

This simple declaration makes a few assumptions about your environment:

* There is an object named `Person`
* `Person` has a `.find` method that takes an `id`
* There is a `params` method that returns a `Hash`-like structure which has
  either an `id` key or a `person_id` key.

*Phew* that's a lot of assumptions. Thankfully those are all overridable for
you control freaks out there (see [advanced usage](/advanced)).

What following those conventions gets you is an instance of `Person`,
retrieved from the database and initialized with all of it's values.

Let's take a look at an example request based on the above exposure (that's
how we refer to a call to the `expose` macro):

### `GET /people/42`

This assumes you have a route that looks something like this:

    resources :people

In the default configuration `expose(:person)` will define an instance method
that returns an object found with this query:

    Person.find(42)

Let's say we have a corresponding `Haml` view (because I like `Haml`):

### `app/views/person.haml`

In that view, we would refer to the `person` method that the controller has
made available to us via the call to `expose`:

    %dl
      %dd Name
      %dt= person.name
      %dd Rank
      %dt= person.rank
      %dd Serial Number
      %dd= person.serial_number

Look at all those instance variables we didn't type! Instance variables aside,
we've now got a method from the controller who's implementation can change and
not likewise break the view because we agreed on an interface (namely the
method name `person`).

Oddly enough, retrieving resources isn't the only thing we do in our
applications, so let's take a look at what happens when you want to update a
retrieved resource.

## Updating existing resources

For our purposes, we'll assume the same basic controller setup:

    class Controller
      expose(:person)
    end

All of the previous assumptions are still true about what `decent_exposure`
expects out of your application. We start to add some additional behavior
though, when we detect that you're updating the resource exposed by the
exposure (namely that your request is being interpreted as a `PUT`). Let's
assume the following `update` action in our standard Rails controller:

    class Controller
      expose(:person)

      def update
        if person.save
          redirect_to(person)
        else
          render :edit
        end
      end
    end

Here we see the controller's first attempt to consume the interface provided
by the call to `expose`. That `person` method is available there too. If
you're used to seeing conventional instance variable laden controllers, you
might be astonished by how little code there is there. Even if you're used to
manually creating an interface in your controller (say via private methods)
you're probably still a little flabbergasted at that being all there is to it.

Let's demystify what's happening there by talking about the assumptions
`decent_exposure` is making:

* The `HTTP` verb is a `PUT`, so you want to update the exposed resource
* There is a `params` method that returns a `Hash`-like structure which has a
  `person` key that contains the attributes and values you wish to update the
  `person` resource with.
* The `person` resource exposed has an `#attributes=` method that wants a
  mass-assignable attribute `Hash` sent to it.

Or, plainly put, it's going to try to do this:

    person.attributes = params[:person]

Note that `decent_exposure` does not call `save` on that exposed resource.
That's so you can get and respond to the Boolean value that `#save` called on
an `ActiveRecord` object will return to you (or whatever your framework does
if you're not using `ActiveRecord`).

With a significant amount of busy-work cleared out of the way, you're free to
clearly define the actual meat of the interactions in your controller, as
shown above in our sparse update action. The only thing we really want to do
is redirect if we can save. If we can't save, then re-render our edit view to
display our errors.

If you're so inclined, you can make things even more sparse by using Rails'
`respond_with` method like so:

    class Controller
      respond_to(:html)
      expose(:person)

      def update
        person.save
        respond_with(person)
      end
    end

## Creating a new resource

With the conventions we've covered above, creating a new resource becomes very
easy to understand. We'll assume, again, the same basic structure, now with
more `create` action:

    class Controller
      respond_to(:html)
      expose(:person)

      def create
        person.save
        respond_with(person)
      end
    end

Again, `decent_exposure` behaves a bit differently when you're creating a
resource (and again we detect the `HTTP` verb, in this case `POST`). Here are
the additional assumptions we make:

* The `Person` object responds to `.new` and that method takes an attribute
  hash.

Other than that, we expect much the same as we did when updating an object.
Again we assign all the attributes provided in `params[:person]` and again we
will create the `#person` method that's shared by your controller and it's
views.

## Putting it all together

Here's what a typical `decent_exposure` controller might look like:

    class Controller
      respond_to(:html)
      expose(:person)

      def create
        person.save
        respond_with(person)
      end

      def update
        person.save
        respond_with(person)
      end
    end

You might note the absence of the `new` and `edit` methods. The short story
is: you don't need them. Most people only include those methods to set up
instance variables that the views need. Since we make methods in the
controller that are exposed to the views, there is no longer any need to
define those actions. Rails' default is to just render a view with the name of
the action, which is all we need. In both cases, `decent_exposure` sees that
the request is a `GET` and it prepares the `person` exposure by returning the
associated `Person` instance from the database.

## Where to next?

Most folks will probably want to head over and see [usage](/usage) next
(though really, we've covered the most basic use examples here).

If you're in need of tuning `decent_exposure` to your environment in a more
custom manner (Rails apps are complicated beasts!), you should probably check
out our section on [advanced usage](/advanced).

If you just need to know how you can contribute to `decent_exposure` (we
really need a strategy for `mongoid`, *hint* *hint*), pop over to our section
on [contributing](/contributing).
