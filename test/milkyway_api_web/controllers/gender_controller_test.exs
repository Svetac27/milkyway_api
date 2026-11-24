defmodule MilkywayApiWeb.GenderControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts.Gender
  alias MilkywayApi.Repo

  test "lists genders without authentication and permits frontend origins", %{conn: conn} do
    gender = Repo.insert!(Gender.changeset(%Gender{}, %{name: "Example", key: "example"}))
    without_key = Repo.insert!(%Gender{name: "No key"})

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> get("/api/genders")

    assert %{"data" => data} = json_response(conn, 200)

    assert %{"name" => "Example", "key" => "example"} =
             Enum.find(data, &(&1["id"] == gender.id))

    assert %{"key" => nil} = Enum.find(data, &(&1["id"] == without_key.id))
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no genders exist", %{conn: conn} do
    assert %{"data" => []} = conn |> get("/api/genders") |> json_response(200)
  end
end
