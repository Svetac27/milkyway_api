defmodule MilkywayApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :role, :string, default: "buyer"

    timestamps(type: :utc_datetime)
  end

  @roles ["buyer", "seller", "admin"]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :role])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:password, min: 8, max: 72)
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> put_default_role()
    |> put_hashed_password()
  end

  defp put_default_role(changeset) do
    case get_field(changeset, :role) do
      nil -> put_change(changeset, :role, "buyer")
      _ -> changeset
    end
  end

  defp put_hashed_password(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        change(changeset, hashed_password: Bcrypt.hash_pwd_salt(password))
    end
  end

  defp put_hashed_password(changeset), do: changeset
end
