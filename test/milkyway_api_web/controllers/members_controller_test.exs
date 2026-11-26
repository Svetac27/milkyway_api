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

  test "an authenticated user can retrieve a member by ID", %{conn: conn} do
    member = Repo.insert!(%Member{name: "Example", avatar: "/example.png"})

    assert %{"data" => %{"id" => id, "avatar" => "/example.png"}} =
             conn
             |> put_user_auth(user_fixture())
             |> get("/api/members/#{member.id}")
             |> json_response(200)

    assert id == member.id
  end

  test "an admin can create, partially update, and permanently delete a member", %{conn: conn} do
    admin = user_fixture(%{role: "admin"})

    assert %{"data" => %{"id" => id, "name" => "Example", "active" => false}} =
             conn
             |> put_user_auth(admin)
             |> post("/api/members", Map.put(member_attrs(), "id", 999_999_999))
             |> json_response(201)

    refute id == 999_999_999

    assert %{"data" => %{"id" => ^id, "name" => "Updated", "last_name" => "Person"}} =
             build_conn()
             |> put_user_auth(admin)
             |> put("/api/members/#{id}", %{"name" => "Updated", "id" => 999_999_999})
             |> json_response(200)

    assert response(build_conn() |> put_user_auth(admin) |> delete("/api/members/#{id}"), 204) ==
             ""

    assert Repo.get(Member, id) == nil
  end

  test "partial updates work on older records with missing fields", %{conn: conn} do
    admin = user_fixture(%{role: "admin"})
    member = Repo.insert!(%Member{name: "Example"})

    assert %{"data" => %{"name" => "Updated", "avatar" => nil}} =
             conn
             |> put_user_auth(admin)
             |> put("/api/members/#{member.id}", %{"name" => "Updated"})
             |> json_response(200)
  end

  test "creates a member with nullable fields and null active", %{conn: conn} do
    admin = user_fixture(%{role: "admin"})

    assert %{"data" => %{"name" => "Minimal", "active" => false, "avatar" => nil}} =
             build_conn()
             |> put_user_auth(admin)
             |> post("/api/members", %{"name" => "Minimal"})
             |> json_response(201)

    attrs =
      Map.merge(member_attrs(), %{
        "active" => nil,
        "middle_name" => nil,
        "phone" => nil,
        "jmbg" => nil,
        "registration" => nil,
        "medical" => nil,
        "first_registration" => nil,
        "last_registration" => nil
      })

    assert %{"data" => data} =
             conn |> put_user_auth(admin) |> post("/api/members", attrs) |> json_response(201)

    assert data["name"] == "Example"
    assert data["active"] == false

    for field <-
          ~w(middle_name phone jmbg registration medical first_registration last_registration) do
      assert Map.fetch!(data, field) == nil
    end

    stored = Repo.get!(Member, data["id"])
    assert stored.active == false
    assert stored.jmbg == nil
  end

  test "updates clear nullable fields and reset null active to false", %{conn: conn} do
    admin = user_fixture(%{role: "admin"})

    member =
      Repo.insert!(%Member{
        name: "Example",
        active: true,
        avatar: "/example.png",
        phone: "123",
        birthdate: ~D[2000-01-01]
      })

    fields =
      ~w(avatar middle_name last_name gender email phone generation birthdate category group jmbg registration medical first_registration last_registration)

    attrs = Map.new(fields, &{&1, nil}) |> Map.put("active", nil)

    assert %{"data" => data} =
             conn
             |> put_user_auth(admin)
             |> put("/api/members/#{member.id}", attrs)
             |> json_response(200)

    assert data["name"] == "Example"
    assert data["active"] == false
    for field <- fields, do: assert(Map.fetch!(data, field) == nil)
    stored = Repo.get!(Member, member.id)
    assert stored.active == false
    assert stored.avatar == nil
    assert stored.birthdate == nil
  end

  test "write operations require an admin", %{conn: conn} do
    member = Repo.insert!(%Member{name: "Example"})
    buyer = user_fixture()

    for {method, path, body} <- [
          {:post, "/api/members", member_attrs()},
          {:put, "/api/members/#{member.id}", %{"name" => "Changed"}},
          {:delete, "/api/members/#{member.id}", %{}}
        ] do
      assert %{"error" => "unauthorized"} =
               conn |> dispatch(@endpoint, method, path, body) |> json_response(401)

      assert %{"error" => "admin_only"} =
               build_conn()
               |> put_user_auth(buyer)
               |> dispatch(@endpoint, method, path, body)
               |> json_response(403)
    end

    assert Repo.get!(Member, member.id).name == "Example"
  end

  test "returns validation errors for missing or invalid fields", %{conn: conn} do
    admin = user_fixture(%{role: "admin"})
    member = Repo.insert!(%Member{name: "Example"})

    assert %{"error" => "validation_failed", "details" => %{"name" => _}} =
             conn |> put_user_auth(admin) |> post("/api/members", %{}) |> json_response(422)

    for attrs <- [%{"name" => ""}, %{"name" => "Example", "birthdate" => "not-a-date"}] do
      assert %{"error" => "validation_failed"} =
               build_conn()
               |> put_user_auth(admin)
               |> post("/api/members", attrs)
               |> json_response(422)
    end

    for attrs <- [
          %{"name" => nil},
          %{"name" => ""},
          %{"birthdate" => "not-a-date"},
          %{"active" => "invalid"}
        ] do
      assert %{"error" => "validation_failed"} =
               build_conn()
               |> put_user_auth(admin)
               |> put("/api/members/#{member.id}", attrs)
               |> json_response(422)
    end
  end

  test "missing and malformed member IDs return 404", %{conn: conn} do
    admin = user_fixture(%{role: "admin"})

    for id <- ["999999999", "invalid", "9223372036854775808"],
        method <- [:get, :put, :delete] do
      assert %{"error" => "not_found"} =
               conn
               |> put_user_auth(admin)
               |> dispatch(@endpoint, method, "/api/members/#{id}", %{})
               |> json_response(404)
    end
  end

  defp member_attrs do
    %{
      "avatar" => "/avatars/example.png",
      "name" => "Example",
      "middle_name" => "Middle",
      "last_name" => "Person",
      "gender" => "example",
      "email" => "member@example.com",
      "phone" => "123",
      "generation" => "2020",
      "birthdate" => "2000-01-01",
      "category" => "example",
      "group" => "example",
      "jmbg" => "123",
      "registration" => "2020-01-01",
      "medical" => "2020-01-01",
      "first_registration" => "2020-01-01",
      "last_registration" => "2020-01-01"
    }
  end
end
