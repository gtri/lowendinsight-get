# lowendinsight-get

Super simple POST API to get a LowEndInsight report

See `lowendinsight`'s readme for me details on the underlying
functionality.  This is just the API to provide the library with
something to evaluate.

## Run

`mix deps.get && mix run --no-halt`

## Run++

`MIX_ENV=prod mix run --no-halt`

This'll attempt to connect to redis for event transaction storage.
Note, the config/prod.exs config points to the expected Redis store.  If
no connection can be made, logging will track the event.  Not entirely
sure how this will play out, perhaps sidecar tracking of logging is the
real event store.

## TODO'ing

Am working to get this thing deliverable to K8s clusters.  The container
can be found in a regular place soon...
