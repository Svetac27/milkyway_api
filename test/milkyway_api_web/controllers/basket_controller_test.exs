defmodule MilkywayApiWeb.BasketControllerTest do
  use MilkywayApiWeb.ConnCase, async: true

  alias MilkywayApi.Accounts
  alias MilkywayApi.Catalog
  alias MilkywayApi.Orders

  describe "basket" do
    test "buyer can add product to basket", %{conn: conn} do
      buyer = create_user!("buyer")
      seller = create_user!("seller")
      product = create_product!(seller.id)

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(buyer.id))
        |> post("/api/products/#{product.id}/basket")

      assert %{"data" => returned_product} = json_response(conn, 201)
      assert returned_product["id"] == product.id
    end

    test "seller cannot add product to basket", %{conn: conn} do
      seller = create_user!("seller")
      product = create_product!(seller.id)

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(seller.id))
        |> post("/api/products/#{product.id}/basket")

      assert %{"error" => "buyer_only"} = json_response(conn, 403)
    end

    test "buyer can list own basket products", %{conn: conn} do
      buyer = create_user!("buyer")
      seller = create_user!("seller")
      product = create_product!(seller.id)

      assert {:ok, _basket_item} =
               Orders.add_to_basket(%{buyer_id: buyer.id, product_id: product.id})

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(buyer.id))
        |> get("/api/basket")

      assert %{"data" => products} = json_response(conn, 200)
      assert Enum.any?(products, fn basket_product -> basket_product["id"] == product.id end)
    end

    test "buyer can delete own basket item", %{conn: conn} do
      buyer = create_user!("buyer")
      seller = create_user!("seller")
      product = create_product!(seller.id)

      assert {:ok, basket_item} =
               Orders.add_to_basket(%{buyer_id: buyer.id, product_id: product.id})

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(buyer.id))
        |> delete("/api/basket/#{basket_item.id}")

      assert response(conn, 204)
      assert is_nil(Orders.get_basket_item(basket_item.id))
    end

    test "buyer cannot delete someone else's basket item", %{conn: conn} do
      buyer1 = create_user!("buyer")
      buyer2 = create_user!("buyer")
      seller = create_user!("seller")
      product = create_product!(seller.id)

      assert {:ok, basket_item} =
               Orders.add_to_basket(%{buyer_id: buyer1.id, product_id: product.id})

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(buyer2.id))
        |> delete("/api/basket/#{basket_item.id}")

      assert %{"error" => "not_owner"} = json_response(conn, 403)
    end

    test "seller cannot delete basket item", %{conn: conn} do
      buyer = create_user!("buyer")
      seller = create_user!("seller")
      product = create_product!(seller.id)

      assert {:ok, basket_item} =
               Orders.add_to_basket(%{buyer_id: buyer.id, product_id: product.id})

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(seller.id))
        |> delete("/api/basket/#{basket_item.id}")

      assert %{"error" => "buyer_only"} = json_response(conn, 403)
    end

    test "unauthenticated user cannot delete basket item", %{conn: conn} do
      buyer = create_user!("buyer")
      seller = create_user!("seller")
      product = create_product!(seller.id)

      assert {:ok, basket_item} =
               Orders.add_to_basket(%{buyer_id: buyer.id, product_id: product.id})

      conn = delete(conn, "/api/basket/#{basket_item.id}")

      assert %{"error" => "unauthorized"} = json_response(conn, 401)
    end

    test "delete non-existent basket item returns 404", %{conn: conn} do
      buyer = create_user!("buyer")

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(buyer.id))
        |> delete("/api/basket/9999")

      assert %{"error" => "not_found"} = json_response(conn, 404)
    end
  end

  describe "product buyers" do
    test "seller owner can list buyers for product", %{conn: conn} do
      seller = create_user!("seller")
      buyer = create_user!("buyer")
      product = create_product!(seller.id)

      assert {:ok, _basket_item} =
               Orders.add_to_basket(%{buyer_id: buyer.id, product_id: product.id})

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(seller.id))
        |> get("/api/products/#{product.id}/buyers")

      assert %{"data" => buyers} = json_response(conn, 200)
      assert Enum.any?(buyers, fn listed_buyer -> listed_buyer["id"] == buyer.id end)
    end

    test "non-owner seller cannot list buyers", %{conn: conn} do
      owner_seller = create_user!("seller")
      another_seller = create_user!("seller")
      product = create_product!(owner_seller.id)

      conn =
        conn
        |> put_req_header("x-user-id", Integer.to_string(another_seller.id))
        |> get("/api/products/#{product.id}/buyers")

      assert %{"error" => "not_owner"} = json_response(conn, 403)
    end
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
