# lowendinsight-get

Super simple POST API to get a LowEndInsight report

![default_elixir_ci](https://github.com/kitplummer/lowendinsight-get/workflows/default_elixir_ci/badge.svg)

See `lowendinsight`'s README for more details on the underlying
functionality.  This is just the API to provide the library with
something to evaluate.

https://github.com/gtri/lowendinsight

The workflow for this API is asynchronous.  The POST to `/v1/analyze` will return immediately, providing you with a `uuid` for the job.

You then can do a GET to `/v1/analyze/:uuid` (with your newly minted ID) to retrieve the results.  The analyzer job will change `state` from "incomplete" to "complete" when the analysis is done.

Unfortunately some git repositories are just huge, and will take time to download - even a single branch.

## Configuration

Look at `config/config.exs` or if you're building your own container
`rel/config/prod.exs` (which is used as the container's prod config :)) for how to set the governance par levels, and the cache TTL.

The configuration items are also explained at
https://github.com/gtri/lowendinsight in more detail.

## Run

### Development

You can run with `mix` but you'll have to ensure a provided Redis service is available and the correct configuration is referenced in `config/config.exs`.  Then you run: `mix run --no-halt`.

Don't forget to get fetch the dependencies:

```bash
mix deps.get && mix run --no-halt
```

### Production

Well, if you're at this point I'd recommend using the Docker Compose or Kubernetes deployments.  Configuration for both are found in the repo.

The `docker-compose.yml` will spin up a Redis db and the LowEndInsight containers, exposing the services.  You can simply run `docker-compose up` to launch things.

Within the `k8s` subdirectory you'll find configuration files for both Redis (single node configuration) and LowEndInsight.  For example:

```bash
➜  kubectl apply -f k8s/redis-master-deployment.yaml
deployment.apps/redis-master created
➜  kubectl apply -f k8s/redis-master-service.yaml
service/redis-master created
➜  kubectl apply -f k8s/deployment.yaml
deployment.apps/lei-get created
➜  kubectl apply -f k8s/service.yaml
service/lei-get created
➜  kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/lei-get-7f4bd755c9-7m6fz        1/1     Running   0          23s
pod/redis-master-7db7f6579f-x97df   1/1     Running   0          37s


NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/kubernetes     ClusterIP      10.96.0.1       <none>        443/TCP          17d
service/lei-get        LoadBalancer   10.96.15.135    <pending>     4000:32224/TCP   17s
service/redis-master   ClusterIP      10.96.247.238   <none>        6379/TCP         33s


NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/lei-get        1/1     1            1           23s
deployment.apps/redis-master   1/1     1            1           37s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/lei-get-7f4bd755c9        1         1         1       23s
replicaset.apps/redis-master-7db7f6579f   1         1         1       37s
```

### Heroku

It's also possible to run this in Heroku using the Elixir buildpack.  The Redis configuration requires the Heroku Redis addon which will set the REDIS_URL environment variable.  The `procfile` at the root of the repo is used by the buildpack to run the app.  While this isn't a Phoenix app I used this URL as a guide:

https://hexdocs.pm/phoenix/heroku.html

And this one for the Redis setup:

https://devcenter.heroku.com/articles/heroku-redis#provisioning-the-add-on

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

OpenAPI/Swagger docs to come soon...
[Issue: https://github.com/kitplummer/lowendinsight-get/issues/5]

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
