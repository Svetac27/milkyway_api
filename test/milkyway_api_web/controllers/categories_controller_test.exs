defmodule MilkywayApiWeb.CategoriesControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Catalog.Category
  alias MilkywayApi.Repo

  test "lists categories without authentication and permits frontend origins", %{conn: conn} do
    category = Repo.insert!(Category.changeset(%Category{}, %{name: "Example", key: "example"}))
    without_key = Repo.insert!(%Category{name: "No key"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/categories")

    assert %{"data" => data} = json_response(conn, 200)

    assert %{"name" => "Example", "key" => "example"} =
             Enum.find(data, &(&1["id"] == category.id))

    assert %{"key" => nil} = Enum.find(data, &(&1["id"] == without_key.id))
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no categories exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/categories") |> json_response(200)
  end
end
