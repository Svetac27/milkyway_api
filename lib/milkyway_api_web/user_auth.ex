defmodule MilkywayApiWeb.UserAuth do
  import Plug.Conn

  alias MilkywayApi.Accounts
  alias MilkywayApi.Accounts.User
  alias MilkywayApi.Repo

  def init(opts), do: opts

  def call(conn, :fetch_current_user) do
    assign(conn, :current_user, fetch_current_user(conn))
  end

  def call(conn, _opts), do: conn

  defp fetch_current_user(conn) do
    case get_bearer_token(conn) do
      {:ok, token} ->
        Accounts.get_user_by_token(token)

      :error ->
        fetch_current_user_from_legacy_header(conn)
    end
  end

  defp fetch_current_user_from_legacy_header(conn) do
    conn
    |> get_req_header("x-user-id")
    |> List.first()
    |> parse_user_id()
    |> case do
      {:ok, user_id} -> Repo.get(User, user_id)
      :error -> nil
    end
  end

  defp get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] when byte_size(token) > 0 -> {:ok, token}
      _ -> :error
    end
  end

  defp parse_user_id(nil), do: :error

  defp parse_user_id(value) do
    case Integer.parse(value) do
      {user_id, ""} when user_id > 0 -> {:ok, user_id}
      _ -> :error
    end
  end
end
