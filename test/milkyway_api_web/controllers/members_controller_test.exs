defmodule MilkywayApiWeb.MembersControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  import MilkywayApi.AccountsFixtures

  alias MilkywayApi.Accounts.Member
  alias MilkywayApi.Repo

  test "lists members for authenticated users and permits frontend origins", %{conn: conn} do
    member =
      Repo.insert!(%Member{
        name: "Example",
        avatar: "/avatars/example.png",
        jmbg: "123",
        medical: ~D[2026-01-01]
      })

    without_avatar = Repo.insert!(%Member{name: "Without avatar"})
    user = user_fixture()

    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> put_user_auth(user)
      |> get("/api/members")

    assert %{"data" => members} = json_response(conn, 200)

    assert %{
             "id" => _,
             "name" => "Example",
             "avatar" => "/avatars/example.png",
             "jmbg" => "123",
             "medical" => "2026-01-01"
           } =
             Enum.find(members, &(&1["id"] == member.id))

    assert %{"avatar" => nil} = Enum.find(members, &(&1["id"] == without_avatar.id))
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
  end

  test "returns an empty list when no members exist", %{conn: conn} do
    assert %{"data" => []} =
             conn |> put_user_auth(user_fixture()) |> get("/api/members") |> json_response(200)
  end

  test "rejects missing and invalid tokens", %{conn: conn} do
    assert %{"error" => "unauthorized"} = conn |> get("/api/members") |> json_response(401)

    assert %{"error" => "unauthorized"} =
             build_conn()
             |> put_req_header("authorization", "Bearer invalid")
             |> get("/api/members")
             |> json_response(401)
  end
end
