defmodule MilkywayApiWeb.GroupsControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts.Groups
  alias MilkywayApi.Repo

  test "lists groups without authentication and permits frontend origins", %{conn: conn} do
    group = Repo.insert!(%Groups{name: "Example"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/groups")

    assert %{"data" => [%{"id" => id, "name" => "Example"}]} = json_response(conn, 200)
    assert id == group.id
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no groups exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/groups") |> json_response(200)
  end
end
