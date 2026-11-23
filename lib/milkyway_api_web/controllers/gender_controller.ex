defmodule MilkywayApiWeb.GenderController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Accounts

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_genders()})
  end
end
