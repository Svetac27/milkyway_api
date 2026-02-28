defmodule MilkywayApi.Repo do
  use Ecto.Repo,
    otp_app: :milkyway_api,
    adapter: Ecto.Adapters.Postgres
end
