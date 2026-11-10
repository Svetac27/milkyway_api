defmodule MilkywayApiWeb.ProductAdminTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts
  alias MilkywayApi.Catalog
  alias MilkywayApi.Orders

  test "admin can manage products owned by other sellers", %{conn: conn} do
    admin = create_user!("admin")
    seller = create_user!("seller")
    product = create_product!(seller.id)

    update_conn =
      conn
      |> put_user_auth(admin)
      |> patch("/api/products/#{product.id}", %{"price" => 900})

    assert %{"data" => %{"price" => 900}} = json_response(update_conn, 200)

    delete_conn =
      build_conn()
      |> put_user_auth(admin)
      |> delete("/api/products/#{product.id}")

    assert response(delete_conn, 204)
    refute Enum.any?(Catalog.list_products(), &(&1.id == product.id))
  end

  test "admin can create products", %{conn: conn} do
    admin = create_user!("admin")

    conn =
      conn
      |> put_user_auth(admin)
      |> post("/api/products", %{
        "title" => "Laptop",
        "description" => "Good condition",
        "price" => 1200,
        "status" => "active",
        "location" => "Belgrade"
      })

    assert %{"data" => %{"seller_id" => seller_id}} = json_response(conn, 201)
    assert seller_id == admin.id
  end

  test "admin can list buyers for any seller's product", %{conn: conn} do
    admin = create_user!("admin")
    seller = create_user!("seller")
    buyer = create_user!("buyer")
    product = create_product!(seller.id)

    assert {:ok, _basket_item} =
             Orders.add_to_basket(%{buyer_id: buyer.id, product_id: product.id})

    conn =
      conn
      |> put_user_auth(admin)
      |> get("/api/products/#{product.id}/buyers")

    assert %{"data" => buyers} = json_response(conn, 200)
    assert Enum.any?(buyers, &(&1["id"] == buyer.id))
  end

  defp create_user!(role) do
    {:ok, user} =
      Accounts.create_user(%{
        email: "#{role}-#{System.unique_integer([:positive])}@example.com",
        password: "password123",
        role: role
      })

    user
  end

  defp create_product!(seller_id) do
    {:ok, product} =
      Catalog.create_product(%{
        title: "Laptop",
        description: "Good condition",
        price: 1200,
        status: "active",
        location: "Belgrade",
        seller_id: seller_id
      })

    product
  end
end
