defmodule MilkywayApiWeb.UserAuth do
  import Plug.Conn

  alias MilkywayApi.Accounts

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
        nil
    end
  end

  defp get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] when byte_size(token) > 0 -> {:ok, token}
      _ -> :error
    end
  end
end
