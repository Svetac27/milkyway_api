defmodule MilkywayApi.OrdersTest do
  use MilkywayApi.DataCase

  alias MilkywayApi.Orders

  describe "purchase_requests" do
    alias MilkywayApi.Orders.PurchaseRequest

    import MilkywayApi.AccountsFixtures
    import MilkywayApi.CatalogFixtures
    import MilkywayApi.OrdersFixtures

    @invalid_attrs %{message: nil, status: nil}

    test "list_purchase_requests/0 returns all purchase_requests" do
      purchase_request = purchase_request_fixture()
      assert Orders.list_purchase_requests() == [purchase_request]
    end

    test "get_purchase_request!/1 returns the purchase_request with given id" do
      purchase_request = purchase_request_fixture()
      assert Orders.get_purchase_request!(purchase_request.id) == purchase_request
    end

    test "create_purchase_request/1 with valid data creates a purchase_request" do
      buyer = user_fixture(%{role: "buyer"})
      product = product_fixture()

      valid_attrs = %{
        message: "some message",
        status: "pending",
        product_id: product.id,
        buyer_id: buyer.id
      }

      assert {:ok, %PurchaseRequest{} = purchase_request} =
               Orders.create_purchase_request(valid_attrs)

      assert purchase_request.message == "some message"
      assert purchase_request.status == "pending"
    end

    test "create_purchase_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_purchase_request(@invalid_attrs)
    end

    test "update_purchase_request/2 with valid data updates the purchase_request" do
      purchase_request = purchase_request_fixture()
      update_attrs = %{message: "some updated message", status: "accepted"}

      assert {:ok, %PurchaseRequest{} = purchase_request} =
               Orders.update_purchase_request(purchase_request, update_attrs)

      assert purchase_request.message == "some updated message"
      assert purchase_request.status == "accepted"
    end

    test "update_purchase_request/2 with invalid data returns error changeset" do
      purchase_request = purchase_request_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Orders.update_purchase_request(purchase_request, @invalid_attrs)

      assert purchase_request == Orders.get_purchase_request!(purchase_request.id)
    end

    test "delete_purchase_request/1 deletes the purchase_request" do
      purchase_request = purchase_request_fixture()
      assert {:ok, %PurchaseRequest{}} = Orders.delete_purchase_request(purchase_request)

      assert_raise Ecto.NoResultsError, fn ->
        Orders.get_purchase_request!(purchase_request.id)
      end
    end

    test "change_purchase_request/1 returns a purchase_request changeset" do
      purchase_request = purchase_request_fixture()
      assert %Ecto.Changeset{} = Orders.change_purchase_request(purchase_request)
    end
  end

  describe "basket_items" do
    import MilkywayApi.AccountsFixtures
    import MilkywayApi.CatalogFixtures
    import MilkywayApi.OrdersFixtures

    test "add_to_basket/1 creates a basket item" do
      basket_item = basket_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Orders.add_to_basket(%{
                 product_id: basket_item.product_id,
                 buyer_id: basket_item.buyer_id
               })
    end

    test "list_basket_products_for_buyer/1 returns buyer selected products" do
      buyer = user_fixture(%{role: "buyer"})
      product = product_fixture()

      assert {:ok, _basket_item} =
               Orders.add_to_basket(%{product_id: product.id, buyer_id: buyer.id})

      products = Orders.list_basket_products_for_buyer(buyer.id)
      assert Enum.any?(products, fn basket_product -> basket_product.id == product.id end)
    end

    test "list_buyers_for_product/1 returns buyers for product" do
      buyer = user_fixture(%{role: "buyer"})
      product = product_fixture()

      assert {:ok, _basket_item} =
               Orders.add_to_basket(%{product_id: product.id, buyer_id: buyer.id})

      buyers = Orders.list_buyers_for_product(product.id)
      assert Enum.any?(buyers, fn basket_buyer -> basket_buyer.id == buyer.id end)
    end
  end
end
