defmodule MilkywayApi.Release do
  @moduledoc false

  @app :milkyway_api

  def migrate do
    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end
end
