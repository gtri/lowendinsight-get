# lowendinsight-get

Super simple POST API to get a LowEndInsight report

See `lowendinsight`'s README for me details on the underlying
functionality.  This is just the API to provide the library with
something to evaluate.

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

```http
# get usage HTML
GET /
# post a single `url` for a basic report
POST /            {"url":"some git url"}
# post a multiple `urls` for an aggregate report
POST /v1/analyze  {"urls":["some git url", "some other git url"]} 
```

## ROADMAP

- get this thing deliverable to K8s clusters. 
  - The container can be found in a regular place soon...
