# Trailblazer::Container

The `trailblazer-container` gem allows using `dry-container` to configure dependencies and inject them into your operations. This enables you to omit hard-wiring of constants within operations, use `dry-system` for loading, and introduces a new testing approach.

## Overview

Use a `dry-container` to configure your apps dependencies.

```ruby
container = Dry::Container.new
container.namespace('song') do
  namespace('create') do
    register('model.class') { Song }  # "song.create.model.class": Song
    register('contract.default.class') { Song::Form::Create } # "song.create.contract.default.class": Song
  end
end
container.register('logger') { Rails.application.logger } # you can maintain "global" dependencies, too.
```

With a container, your operation is not required to hard-wire constants in macros or steps. For example, many macros such as [`Model()`](https://trailblazer.to/2.1/docs/operation.html#operation-macros-model-dependency-injection
) or [`Contract::Build()`](https://trailblazer.to/2.1/docs/operation.html#operation-contract-build-dependency-injection-contract-class) alternatively allow constants or configuration ("dependencies") to be injected.


```ruby
class Song
  module Operation
    class Create < Trailblazer::Operation
      step Model()              # this macro needs {:"model.class"}
      step Contract::Build()    # and this needs {:"contract.class"}
      step :log

      def log(ctx, logger:, **) # {:logger} is also from the container!
        logger.warn "Everything is cool!"
      end
    end
  end
end # Song
```

Using `Container::Namespaced` will bind the `dry-container` to a specific operation, providing an automatic namespace such as `song.create`. The operation doesn't even know anything about the container.

```ruby
ctx              = Trailblazer::Context({params: {id: 1}}, {})
create_container = Trailblazer::Container::Namespaced.new(container, ctx, "song.create") # here, we provide the namespace.

signal, (ctx, _) = Trailblazer::Activity::TaskWrap.invoke(Song::Operation::Create, [create_container, {}])
```

## Status

This gem is still experimental. Please play around with it and [let us know](https://trailblazer.zulipchat.com) what works for you.

We will improve its usability in the coming weeks.
