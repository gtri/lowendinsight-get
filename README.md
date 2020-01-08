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

## API

Pretty simple stuff:

GET / - returns usage HTML
POST / {"url":"some git url"} - returns basic report
POST /v1/analyze {"urls":["some git url", "some other git url"]} -
returns aggregate report

Swagger docs to come soon...

## License

See LICENSE

# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.
