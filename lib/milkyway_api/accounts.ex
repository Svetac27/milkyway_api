defmodule MilkywayApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MilkywayApi.Repo

  alias MilkywayApi.Accounts.User

  @token_salt "user_auth"

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a user by email.

  Returns `nil` if no user exists.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email(_), do: nil

  @doc """
  Authenticates a user by email and password.

  Returns `{:ok, user}` when credentials are valid, otherwise `:error`.
  """
  def authenticate_user(email, password)
      when is_binary(email) and is_binary(password) do
    case get_user_by_email(email) do
      %User{} = user ->
        if safe_verify_password(password, user.hashed_password) do
          {:ok, user}
        else
          :error
        end

      nil ->
        Bcrypt.no_user_verify()
        :error
    end
  end

  def authenticate_user(_, _) do
    Bcrypt.no_user_verify()
    :error
  end

  defp safe_verify_password(password, hashed_password)
       when is_binary(password) and is_binary(hashed_password) do
    try do
      Bcrypt.verify_pass(password, hashed_password)
    rescue
      _ -> false
    end
  end

  defp safe_verify_password(_password, _hashed_password), do: false

  @doc """
  Creates a signed token for a user.
  """
  def generate_user_token(%User{} = user) do
    Phoenix.Token.sign(MilkywayApiWeb.Endpoint, @token_salt, user.id)
  end

  @doc """
  Verifies a signed user token and returns the user on success.
  """
  def get_user_by_token(token) when is_binary(token) do
    case Phoenix.Token.verify(MilkywayApiWeb.Endpoint, @token_salt, token, max_age: 86_400) do
      {:ok, user_id} -> Repo.get(User, user_id)
      {:error, _reason} -> nil
    end
  end

  def get_user_by_token(_), do: nil

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
