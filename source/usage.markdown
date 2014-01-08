# How the?

Well, let's look into just how the&hellip; Let us consider this following
components in your Rails app:

**Models**

```ruby
class Company < ActiveRecord::Base
  has_many :people
end

class Person < ActiveRecord::Base; end
```

**Routes**

```ruby
resources :companies do
  resources :people
end
```

And let us further suppose that we're going to be doing some work with people
scoped under companies. With that as our set-up, let's look into the
`decent_exposure` API!

## `.expose(name, options={}, &block)`

This is the main interface that you'll interact with `decent_exposure`
through. It has one required argument and two optional arguments. For many
cases, you'll only need to supply the first, required argument. We'll explore
this first.

Consider the following controller:

```ruby
class PeopleController < ApplicationController

  expose(:person)

  def create
    if person.save
      redirect_to(people_path)
    else
      render :edit
    end
  end

  def update
    if person.save
      redirect_to(person)
    else
      render :edit
    end
  end

  def destroy
    person.destroy && redirect_to(people_path)
  end

end
```

If what we need is a full lifecycle of CRUD operations for our controller, then
that's all the code we need to do it.

In our view, we just access the `person` method that's exposed to the view (we
accomplish this by using Rails' builtin [`helper_method`][helper] macro under
the hood). Do this anywhere you might ordinarily have used the `@person`
instance variable, if you were following the same naming convention.

That's the nuts and bolts of it. However, what we want in a Rails' application
is rarely that simple, so let's have a look at that options hash!

## Configuring `.expose`

Here's a list of valid options you can pass as the second argument to
`.expose`:

<dl>
  <dt><code>:ancestor</code></dt>
  <dd>Symbolized name of another exposure to scope from</dd>
  <dt><code>:model</code></dt>
  <dd>Symbolized name of the model to use for that exposure</dd>
  <dt><code>:params</code><dt>
  <dd>Symbolized name of the method to call on the controller to get a
  <code>params</code> hash</dd>
  <dt><code>:finder</code></dt>
  <dd>Symbolized name of the method used to find the record</dd>
  <dt><code>:finder_parameter</code></dd>
  <dd>Symbolized name of the <code>params</code> attribute containing the
  <code>finder</code> method's unique identifier</dd>
</dl>

[helper]: http://goo.gl/wne0F

Next let's look at some potential usage for each of these options:

### `:ancestor`

This will be a frequently used option in most applications. In fact, probably
90% of the time this is all the additional configuration you'll want to do.

Looking back at our example models, we note that a `Company` `has_many`
`people`. In order to represent this in our controller, we would previously
have written something like this:

```ruby
class PeopleController < ApplicationController

  def update
    @company = Company.find(params[:company_id])
    @person = @company.people.find(params[:id])
    if @person.save
      redirect_to(people_path)
    else
      render :edit
    end
  end

end
```

With `decent_exposure` we approach that in a declarative fashion, like so:


```ruby
class PeopleController < ApplicationController

  expose(:company)
  expose(:people, ancestor: :company)

  def update
    if person.save
      redirect_to(people_path)
    else
      render :edit
    end
  end

end
```

The scoping of the resource to it's parent (widely considered a best practice)
is handled for you, so long as you specify the `:ancestor`.


### `:model`

This is the another option you'll likely get some mileage out of.
Extrapolating further on our supposed object model, let us assume that we have
a need to see a `Person` in both a public and private fashion. We may want to
signify that by changing the name of our interface method depending on the
situation:

```ruby
class PeopleController < ApplicationController
  expose(:person)
end

class EmployeesController < ApplicationController
  expose(:employee, model: :person)
end
```

Naming is both important and hard, so there's no sense in `decent_exposure`
handicapping your interactions with your object system... Call a duck a duck
and an employee an employee.

### `:params`

This may not be something you often run across the need for, but I suspect a
few framework implementers or people dealing with external posts might enjoy
this bit of configuration.

The `:params` option lets you specify the name of a method, as a symbol to
call in lieu of the standard `ActionController#params` method:

```ruby
class PeopleController < ApplicationController
  expose(:people, params: :scrubbed_params)

  def scrubbed_params
    params.slice(:foo,:bar,:baz)
  end
end
```

The behavior of an exposure specifying it's `:params` method is otherwise
unchanged.

### `:finder` and `:finder_parameter`

You'll often find these two together, so we'll discuss them together. The
`:finder` option allows you to specify which method to call on the exposure's
model to "find" the referenced resource.

Let's assume the following route:

```ruby
get 'people/:slug' => 'people#show'
```

This means our faithful `params[:id]` isn't going to work, but only at the
expense of having a more descriptive name, because apparently we're going to
have user-specified URLs.

The additional implication here is that we probably don't want to go around
using `Person.find(params[:slug])` anymore either, as a `slug` is not an `id`.

`decent_exposure` answers this problem like so:

```ruby
class PeopleController < ApplicationController
  expose(:people, finder: :find_by_slug, finder_parameter: :slug)
end
```

Where convention isn't what we need or want, we opt for configuration.

## `.expose!(name, options={}, &block)`

By default, `decent_exposure` won't evaluate the exposure until something
calls it. This is "lazy loading" 101, and it's normally a _Very Good Thing_.
Sometimes though, we need to have the results of the exposure eagerly loaded.
This is typically so that the controller can catch and handle errors in the
underlying query. We often need this sort of thing when our friend
[RBAC][rbac] is introduced to the system so we can do things like let an
`ActiveRecord::RecordNotFound` turn into a `404` page.

When you find yourself in need this behavior, just fire off a round: bang!
bang! like so:

```ruby
class PeopleController < ApplicationController
  expose!(:people)
end
```

The method signature is the same, just add a `!` and you opt into
eager-loading. Easy peezy.

## Other topics

From here you may want to look into [advanced usage](advanced.html) or maybe look
into how to go about [contributing](contributing.html).

[rbac]: http://en.wikipedia.org/wiki/Role-based_access_control
