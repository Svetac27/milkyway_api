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

  test "sorts by order ascending, placing null values last and breaking ties by ID", %{conn: conn} do
    last = Repo.insert!(%MemberData{name: "No order"})
    high = Repo.insert!(%MemberData{name: "High", order: 10})
    first = Repo.insert!(%MemberData{name: "First", order: 1})
    second = Repo.insert!(%MemberData{name: "Second", order: 1})

    assert %{"data" => data} = conn |> get("/api/member_data") |> json_response(200)
    assert Enum.map(data, & &1["id"]) == [first.id, second.id, high.id, last.id]
  end
end
