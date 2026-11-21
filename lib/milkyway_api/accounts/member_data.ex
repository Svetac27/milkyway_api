defmodule MilkywayApi.Accounts.MemberData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "member_data" do
    field :name, :string
    field :key, :string
    field :type, :string
    field :hide, :boolean, default: false
    field :order, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_data, attrs) do
    member_data
    |> cast(attrs, [:name, :key, :type, :hide, :order])
    |> validate_required([:name, :key, :type, :hide, :order])
  end
end
