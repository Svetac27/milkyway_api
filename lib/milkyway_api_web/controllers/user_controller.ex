defmodule MilkywayApiWeb.UserController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Accounts
  alias MilkywayApi.Accounts.User

  def index(conn, _params) do
    with :ok <- require_admin(conn.assigns[:current_user]) do
      users =
        Accounts.list_users()
        |> Enum.map(&serialize_user/1)

      json(conn, %{data: users})
    else
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  def show(conn, %{"id" => id}) do
    with :ok <- require_admin(conn.assigns[:current_user]) do
      case Accounts.get_user(id) do
        %User{} = user ->
          json(conn, %{data: serialize_user(user)})

        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "not_found"})
      end
    else
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  def create(conn, params) do
    attrs = Map.take(params, ["email", "password", "role"])

    with :ok <- authorize_creation(conn.assigns[:current_user], attrs) do
      case Accounts.create_user(attrs) do
        {:ok, %User{} = user} ->
          conn
          |> put_status(:created)
          |> json(%{data: serialize_user(user)})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "validation_failed", details: changeset_errors(changeset)})
      end
    else
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  def login(conn, params) do
    email = Map.get(params, "email")
    password = Map.get(params, "password")

    case Accounts.authenticate_user(email, password) do
      {:ok, %User{} = user} ->
        token = Accounts.generate_user_token(user)

        json(conn, %{
          data: %{
            token: token,
            user: serialize_user(user)
          }
        })

      :error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid_credentials"})
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = Map.take(params, ["email", "password", "role"])

    with :ok <- require_admin(conn.assigns[:current_user]) do
      case Accounts.get_user(id) do
        %User{} = user ->
          case Accounts.update_user(user, attrs) do
            {:ok, %User{} = updated_user} ->
              json(conn, %{data: serialize_user(updated_user)})

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{error: "validation_failed", details: changeset_errors(changeset)})
          end

        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "not_found"})
      end
    else
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    with :ok <- require_admin(conn.assigns[:current_user]) do
      case Accounts.get_user(id) do
        %User{} = user ->
          {:ok, _} = Accounts.delete_user(user)
          send_resp(conn, :no_content, "")

        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "not_found"})
      end
    else
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  defp serialize_user(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)
    end)
  end

  defp authorize_creation(user, %{"role" => "admin"}), do: require_admin(user)
  defp authorize_creation(_user, _attrs), do: :ok

  defp require_admin(nil), do: {:error, :unauthorized, "unauthorized"}
  defp require_admin(%{role: "admin"}), do: :ok
  defp require_admin(_user), do: {:error, :forbidden, "admin_only"}

  defp error_response(conn, status, message) do
    conn |> put_status(status) |> json(%{error: message})
  end
end
