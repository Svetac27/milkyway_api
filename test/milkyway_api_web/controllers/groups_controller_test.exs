defmodule MilkywayApiWeb.GroupsControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts.Group
  alias MilkywayApi.Repo

  test "lists groups without authentication and permits frontend origins", %{conn: conn} do
    group = Repo.insert!(Group.changeset(%Group{}, %{name: "Example", key: "example"}))
    without_key = Repo.insert!(%Group{name: "No key"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/groups")

    assert %{"data" => data} = json_response(conn, 200)

    assert %{"name" => "Example", "key" => "example"} =
             Enum.find(data, &(&1["id"] == group.id))

    assert %{"key" => nil} = Enum.find(data, &(&1["id"] == without_key.id))
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no groups exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/groups") |> json_response(200)
  end
end
