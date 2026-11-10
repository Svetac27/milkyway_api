defmodule MilkywayApiWeb.CORSController do
  use MilkywayApiWeb, :controller

  def preflight(conn, _params) do
    send_resp(conn, :no_content, "")
  end
end
