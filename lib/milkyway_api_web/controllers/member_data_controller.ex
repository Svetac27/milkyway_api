defmodule MilkywayApiWeb.MemberDataController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Accounts

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_member_data()})
  end
end
