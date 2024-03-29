# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
ARG ALPINE_VERSION=3.16

FROM elixir:1.14.1-alpine AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME
# The version of the application we are building (required)
ARG APP_VSN
# The environment to build with
ARG MIX_ENV=prod
# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=true
# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=.

ARG RELEASE_ROOT_DIR=/opt/app

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=lowendinsight_get \
    APP_VSN=0.7.2 \
    MIX_ENV=${MIX_ENV} \
    RELEASE_ROOT_DIR=${RELEASE_ROOT_DIR}

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

# This copies our app source code into the build container
COPY . .

RUN HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 MIX_ENV=${MIX_ENV} mix do deps.get, deps.compile, compile

# This step builds assets for the Phoenix app (if there is one)
# If you aren't building a Phoenix app, pass `--build-arg SKIP_PHOENIX=true`
# This is mostly here for demonstration purposes
RUN if [ ! "$SKIP_PHOENIX" = "true" ]; then \
  cd ${PHOENIX_SUBDIR}/assets && \
  yarn install && \
  yarn deploy && \
  cd - && \
  mix phx.digest; \
fi

RUN \
  mkdir -p /opt/built && \
  mkdir -p /opt/app/_build/prod/rel/lowendinsight_get/releases && \
  touch /opt/app/_build/prod/rel/lowendinsight_get/releases/RELEASES && \
  MIX_ENV=${MIX_ENV} mix distillery.release --verbose --env=prod && \
  cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xvzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME

RUN apk update && \
    apk add --no-cache \
      bash \
      git \
      openssl-dev \
      libstdc++ \
      libgcc \
      libcrypto1.1

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME} \
    ERL_AFLAGS="-proto_dist inet6_tcp"

WORKDIR /opt/app

COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
