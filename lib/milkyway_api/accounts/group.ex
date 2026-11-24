defmodule MilkywayApi.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :key, :inserted_at, :updated_at]}

  schema "groups" do
    field :name, :string
    field :key, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :key])
    |> validate_required([:name])
  end
end
