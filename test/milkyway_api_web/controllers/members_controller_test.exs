defmodule MilkywayApiWeb.MembersControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts.Members
  alias MilkywayApi.Repo

  test "lists members without authentication and permits frontend origins", %{conn: conn} do
    member = Repo.insert!(%Members{name: "Example"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/members")

    assert %{"data" => [%{"id" => id, "name" => "Example"}]} = json_response(conn, 200)
    assert id == member.id
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no members exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/members") |> json_response(200)
  end
end
