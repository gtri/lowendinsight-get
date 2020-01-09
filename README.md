# lowendinsight-get

Super simple POST API to get a LowEndInsight report

See `lowendinsight`'s readme for me details on the underlying
functionality.  This is just the API to provide the library with
something to evaluate.

https://github.com/gtri/lowendinsight

## Run

`mix deps.get && mix run --no-halt`

## Run++

`MIX_ENV=prod mix run --no-halt`

This'll attempt to connect to redis for event transaction storage.
Note, the config/prod.exs config points to the expected Redis store.  If
no connection can be made, logging will track the event.  Not entirely
sure how this will play out, perhaps sidecar tracking of logging is the
real event store.

## API

Pretty simple stuff:

* GET / - returns doc HTML

* POST /v1/analyze - returns a JSON report

```bash
curl --location --request POST 'http://localhost:4000/v1/analyze' \
--header 'Content-Type: application/json' \
--data-raw '{"urls":"[https://github.com/kitplummer/lita-cron]"}'
```

Swagger docs to come soon...

## License

See LICENSE

```
# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.
```

## Contributing

Thanks for considering, we need your contributions to help this project come to fruition.

Here are some important resources:

  * Bugs? [Issues](https://github.com/gtri/lowendinsight-get/issues/new) is where to report them

### Style

The repo includes auto-formatting, please run `mix format` to format to
the standard style prescribed by the Elixir project:

https://hexdocs.pm/mix/Mix.Tasks.Format.html
https://github.com/christopheradams/elixir_style_guide

Code docs for functions are expected.  Examples are a bonus:

https://hexdocs.pm/elixir/writing-documentation.html

### Testing

Required. Please write ExUnit test for new code you create.

Use `mix test --cover` to verify that you're maintaining coverage.


### Github Actions

Just getting this built-out.  But the bitbucket-pipeline config is still
here too.

### Submitting changes

Please send a [Pull Request](https://github.com/gtri/lowendinsight-get/pull-requests/) with a clear list of what you've done and why. Please follow Elixir coding conventions (above in Style) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    >
    > A paragraph describing what changed and its impact."