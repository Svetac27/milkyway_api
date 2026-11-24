defmodule MilkywayApi.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :key, :inserted_at, :updated_at]}

  schema "categories" do
    field :name, :string
    field :key, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :key])
    |> validate_required([:name])
  end
end
