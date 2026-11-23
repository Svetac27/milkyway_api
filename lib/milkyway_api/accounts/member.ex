defmodule MilkywayApi.Accounts.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :active,
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

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [
      :active,
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
    ])
    |> validate_required([
      :active,
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
    ])
  end
end
