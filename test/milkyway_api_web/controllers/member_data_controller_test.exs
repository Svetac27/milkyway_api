defmodule MilkywayApiWeb.MemberDataControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts.MemberData
  alias MilkywayApi.Repo

  test "lists member data without authentication and permits frontend origins", %{conn: conn} do
    member_data = Repo.insert!(%MemberData{name: "Example"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/member_data")

    assert %{"data" => [%{"id" => id, "name" => "Example"}]} = json_response(conn, 200)
    assert id == member_data.id
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no member data exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/member_data") |> json_response(200)
  end
end
