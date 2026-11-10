ARG ELIXIR_VERSION=1.18.4
ARG OTP_VERSION=27.3.4.16
ARG DEBIAN_VERSION=bookworm-20260824-slim

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION} AS build

RUN apt-get update -y && apt-get install -y --no-install-recommends build-essential git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config

RUN mix deps.get --only prod && mix deps.compile

COPY lib lib
COPY priv priv

RUN mix compile
RUN mix release

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION} AS app

RUN apt-get update -y && apt-get install -y --no-install-recommends ca-certificates libstdc++6 openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV HOME=/app

COPY --from=build --chown=nobody:nogroup /app/_build/prod/rel/milkyway_api ./

USER nobody:nogroup

CMD ["sh", "-c", "./bin/milkyway_api eval 'MilkywayApi.Release.migrate()' && exec ./bin/milkyway_api start"]
