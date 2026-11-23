defmodule MilkywayApi.Accounts.Gender do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :inserted_at, :updated_at]}

  schema "genders" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gender, attrs) do
    gender
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
