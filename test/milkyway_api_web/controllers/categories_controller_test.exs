defmodule MilkywayApiWeb.CategoriesControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts.Category
  alias MilkywayApi.Repo

  test "lists categories without authentication and permits frontend origins", %{conn: conn} do
    category = Repo.insert!(%Category{name: "Example"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/categories")

    assert %{"data" => [%{"id" => id, "name" => "Example"}]} = json_response(conn, 200)
    assert id == category.id
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no categories exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/categories") |> json_response(200)
  end
end
