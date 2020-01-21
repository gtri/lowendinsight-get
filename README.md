# lowendinsight-get

Super simple POST API to get a LowEndInsight report

See `lowendinsight`'s README for me details on the underlying
functionality.  This is just the API to provide the library with
something to evaluate.

https://github.com/gtri/lowendinsight

The workflow for this API is asynchronous.  The POST to `/v1/analyze` will return immediately, providing you with a `uuid` for the job.

You then can do a GET to `/v1/analyze/:uuid` (with your newly minted ID) to retrieve the results.  The analyzer job will change `state` from "incomplete" to "complete" when the analysis is done.

Unfortunately some git repositories are just huge, and will take time to download - even a single branch.

## Run

### Development

```bash
mix deps.get && mix run --no-halt
```

### Production

```bash
MIX_ENV=prod mix run --no-halt
```

This will attempt to connect to `redis` for event transaction storage.
Note, the `config/prod.exs` config points to the expected Redis store.  If
no connection can be made, logging will track the event.  Not entirely
sure how this will play out, perhaps sidecar tracking of logging is the
real event store.

## REST API

* GET / - returns doc HTML

* POST /v1/analyze - returns a JSON report

```bash
curl --location --request POST 'http://localhost:4000/v1/analyze' \
--header 'Content-Type: application/json' \
--data-raw '{"urls":["https://github.com/kitplummer/lita-cron"]}'
```

returns:

```json
{"metadata":{"times":{"duration":0,"end_time":"","start_time":"2020-01-20T23:18:52.800934Z"}},"report":{"repos":[{"data":{"repo":"https://github.com/kitplummer/lita-cron"}}]},"state":"incomplete","uuid":"38fa1d0c-3bdb-11ea-902c-784f434ce29a"}
```

* GET /v1/analyze/:uuid

`:uuid` here is the analysis job id, that was returned from the POST above.

```bash
curl 'http://localhost:4000/v1/analyze/38fa1d0c-3bdb-11ea-902c-784f434ce29a'
```

if `state` is actually complete, then it'll return:

```json
{"metadata":{"repo_count":1,"risk_counts":{"critical":1},"times":{"duration":1,"end_time":"2020-01-20T23:18:53.491871Z","start_time":"2020-01-20T23:18:52.800934Z"}},"report":{"repos":[{"data":{"config":{"medium_functional_contributors_level":5,"high_contributor_level":3,"high_functional_contributors_level":3,"high_currency_level":52,"high_large_commit_level":0.15,"critical_large_commit_level":0.3,"critical_currency_level":104,"critical_contributor_level":2,"medium_contributor_level":5,"medium_currency_level":26,"medium_large_commit_level":0.05,"critical_functional_contributors_level":2},"repo":"https://github.com/kitplummer/lita-cron","results":{"commit_currency_risk":"critical","commit_currency_weeks":215,"contributor_count":3,"contributor_risk":"medium","functional_contributor_names":["Kit Plummer"],"functional_contributors":1,"functional_contributors_risk":"critical","large_recent_commit_risk":"critical","recent_commit_size_in_percent_of_codebase":0.6266666666666667},"risk":"critical"},"header":{"duration":1,"end_time":"2020-01-20T23:18:53.490764Z","library_version":"0.3.1","source_client":"lei-get","start_time":"2020-01-20T23:18:52.843176Z","uuid":"396366b8-3bdb-11ea-9987-784f434ce29a"}}],"uuid":"396379aa-3bdb-11ea-a2d8-784f434ce29a"},"state":"complete"}
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
