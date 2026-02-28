defmodule MilkywayApiWeb.UserAuth do
  import Plug.Conn

  alias MilkywayApi.Accounts.User
  alias MilkywayApi.Repo

  def init(opts), do: opts

  def call(conn, :fetch_current_user) do
    assign(conn, :current_user, fetch_current_user(conn))
  end

  def call(conn, _opts), do: conn

  defp fetch_current_user(conn) do
    conn
    |> get_req_header("x-user-id")
    |> List.first()
    |> parse_user_id()
    |> case do
      {:ok, user_id} -> Repo.get(User, user_id)
      :error -> nil
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
