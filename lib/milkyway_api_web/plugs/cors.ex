defmodule MilkywayApiWeb.Plugs.CORS do
  import Plug.Conn

  @allowed_methods "GET,POST,PATCH,PUT,DELETE,OPTIONS"
  @allowed_headers "content-type,authorization,x-user-id"
  @max_age "86400"

  def init(opts), do: opts

  def call(conn, _opts) do
    origin = request_origin(conn)

    conn
    |> put_resp_header("access-control-allow-origin", origin)
    |> put_resp_header("access-control-allow-methods", @allowed_methods)
    |> put_resp_header("access-control-allow-headers", @allowed_headers)
    |> put_resp_header("access-control-max-age", @max_age)
    |> put_resp_header("vary", "origin")
  end

  defp request_origin(conn) do
    case get_req_header(conn, "origin") do
      [origin | _] -> origin
      _ -> "*"
    end
  end
end
