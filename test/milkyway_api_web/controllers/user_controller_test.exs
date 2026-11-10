defmodule MilkywayApiWeb.UserControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts
  alias MilkywayApi.Accounts.User
  alias MilkywayApi.Repo

  describe "index" do
    test "returns users without hashed_password", %{conn: conn} do
      user = create_user!()

      conn = get(conn, "/api/users")
      assert %{"data" => users} = json_response(conn, 200)

      assert Enum.any?(users, fn current_user ->
               current_user["id"] == user.id and
                 current_user["email"] == user.email and
                 current_user["role"] == user.role and
                 not Map.has_key?(current_user, "hashed_password")
             end)
    end
  end

  describe "show" do
    test "returns a user by id", %{conn: conn} do
      user = create_user!()

      conn = get(conn, "/api/users/#{user.id}")
      assert %{"data" => returned_user} = json_response(conn, 200)

      assert returned_user["id"] == user.id
      assert returned_user["email"] == user.email
      assert returned_user["role"] == user.role
      refute Map.has_key?(returned_user, "hashed_password")
    end
  end

  describe "create" do
    test "creates user with valid params", %{conn: conn} do
      params = %{
        "email" => unique_email(),
        "password" => "password123",
        "role" => "seller"
      }

      conn = post(conn, "/api/users", params)
      assert %{"data" => user} = json_response(conn, 201)

      assert user["email"] == params["email"]
      assert user["role"] == "seller"
      refute Map.has_key?(user, "hashed_password")
    end

    test "returns validation errors for invalid params", %{conn: conn} do
      conn = post(conn, "/api/users", %{"email" => "invalid", "password" => "short"})

      assert %{"error" => "validation_failed", "details" => details} = json_response(conn, 422)
      assert Map.has_key?(details, "email")
      assert Map.has_key?(details, "password")
    end
  end

  describe "update" do
    test "updates user", %{conn: conn} do
      user = create_user!()
      params = %{"email" => unique_email(), "password" => "password123", "role" => "buyer"}

      conn = patch(conn, "/api/users/#{user.id}", params)
      assert %{"data" => updated_user} = json_response(conn, 200)

      assert updated_user["id"] == user.id
      assert updated_user["email"] == params["email"]
      assert updated_user["role"] == "buyer"
      refute Map.has_key?(updated_user, "hashed_password")
    end
  end

  describe "delete" do
    test "deletes user", %{conn: conn} do
      user = create_user!()

      conn = delete(conn, "/api/users/#{user.id}")
      assert response(conn, 204)

      conn = get(build_conn(), "/api/users/#{user.id}")
      assert json_response(conn, 404)
    end
  end

  describe "login" do
    test "returns token for valid credentials", %{conn: conn} do
      user = create_user!()

      conn =
        post(conn, "/api/login", %{
          "email" => user.email,
          "password" => "password123"
        })

      assert %{"data" => %{"token" => token, "user" => returned_user}} = json_response(conn, 200)
      assert is_binary(token)
      assert String.length(token) > 0
      assert returned_user["id"] == user.id
      assert returned_user["email"] == user.email
      refute Map.has_key?(returned_user, "hashed_password")
    end

    test "returns unauthorized for invalid credentials", %{conn: conn} do
      user = create_user!()

      conn =
        post(conn, "/api/login", %{
          "email" => user.email,
          "password" => "wrong-password"
        })

      assert %{"error" => "invalid_credentials"} = json_response(conn, 401)
    end

    test "supports auth-prefixed login route", %{conn: conn} do
      user = create_user!()

      conn =
        post(conn, "/api/auth/login", %{
          "email" => user.email,
          "password" => "password123"
        })

      assert %{"data" => %{"token" => token}} = json_response(conn, 200)
      assert is_binary(token)
    end

    test "returns unauthorized when stored hash is malformed", %{conn: conn} do
      user =
        Repo.insert!(%User{
          email: unique_email(),
          hashed_password: "not-a-bcrypt-hash",
          role: "buyer"
        })

      conn =
        post(conn, "/api/auth/login", %{
          "email" => user.email,
          "password" => "any-password"
        })

      assert %{"error" => "invalid_credentials"} = json_response(conn, 401)
    end
  end

  describe "cors preflight" do
    test "options request for login returns 204 and cors headers", %{conn: conn} do
      conn =
        conn
        |> put_req_header("origin", "http://localhost:5173")
        |> put_req_header("access-control-request-method", "POST")
        |> put_req_header("access-control-request-headers", "content-type,authorization")
        |> options("/api/auth/login")

      assert response(conn, 204)
      assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
      assert get_resp_header(conn, "access-control-allow-methods") != []
      assert get_resp_header(conn, "access-control-allow-headers") != []
    end
  end

  defp create_user! do
    {:ok, user} =
      Accounts.create_user(%{
        email: unique_email(),
        password: "password123",
        role: "seller"
      })

    user
  end

  defp unique_email do
    "user-#{System.unique_integer([:positive])}@example.com"
  end
end
