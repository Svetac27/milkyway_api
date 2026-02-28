defmodule MilkywayApi.AccountsTest do
  use MilkywayApi.DataCase

  alias MilkywayApi.Accounts

  describe "users" do
    alias MilkywayApi.Accounts.User

    import MilkywayApi.AccountsFixtures

    @invalid_attrs %{role: nil, email: nil, password: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      [listed_user] = Accounts.list_users()
      assert listed_user.id == user.id
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      fetched_user = Accounts.get_user!(user.id)
      assert fetched_user.id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        role: "seller",
        email: "user-#{System.unique_integer([:positive])}@example.com",
        password: "password123"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.role == "seller"
      assert user.email == valid_attrs.email
      assert is_binary(user.hashed_password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        role: "buyer",
        email: "user-#{System.unique_integer([:positive])}@example.com",
        password: "password123"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.role == "buyer"
      assert user.email == update_attrs.email
      assert is_binary(user.hashed_password)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
