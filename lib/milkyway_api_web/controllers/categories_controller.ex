defmodule MilkywayApiWeb.CategoriesController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Accounts

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_categories()})
  end
end
