defmodule MilkywayApiWeb.GroupsController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Accounts

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_groups()})
  end
end
