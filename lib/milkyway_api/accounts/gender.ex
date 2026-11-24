defmodule MilkywayApi.Accounts.Gender do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :key, :inserted_at, :updated_at]}

  schema "genders" do
    field :name, :string
    field :key, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gender, attrs) do
    gender
    |> cast(attrs, [:name, :key])
    |> validate_required([:name])
  end
end
