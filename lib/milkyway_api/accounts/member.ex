defmodule MilkywayApi.Accounts.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :active,
             :avatar,
             :name,
             :middle_name,
             :last_name,
             :gender,
             :email,
             :phone,
             :generation,
             :birthdate,
             :category,
             :group,
             :jmbg,
             :registration,
             :medical,
             :first_registration,
             :last_registration,
             :inserted_at,
             :updated_at
           ]}

  schema "members" do
    field :active, :boolean, default: false
    field :avatar, :string
    field :name, :string
    field :middle_name, :string
    field :last_name, :string
    field :gender, :string
    field :email, :string
    field :phone, :string
    field :generation, :string
    field :birthdate, :date
    field :category, :string
    field :group, :string
    field :jmbg, :string
    field :registration, :date
    field :medical, :date
    field :first_registration, :date
    field :last_registration, :date

    timestamps(type: :utc_datetime)
  end

  @fields [
    :active,
    :avatar,
    :name,
    :middle_name,
    :last_name,
    :gender,
    :email,
    :phone,
    :generation,
    :birthdate,
    :category,
    :group,
    :jmbg,
    :registration,
    :medical,
    :first_registration,
    :last_registration
  ]

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(normalize_active(attrs), @fields)
    |> validate_required([:name, :active])
  end

  @doc false
  def update_changeset(member, attrs) do
    fields =
      if Map.has_key?(attrs, :name) or Map.has_key?(attrs, "name"),
        do: [:name, :active],
        else: [:active]

    member
    |> cast(normalize_active(attrs), @fields)
    |> validate_required(fields)
  end

  defp normalize_active(%{"active" => nil} = attrs), do: Map.put(attrs, "active", false)
  defp normalize_active(%{active: nil} = attrs), do: Map.put(attrs, :active, false)
  defp normalize_active(attrs), do: attrs
end
