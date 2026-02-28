defmodule MilkywayApi.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MilkywayApi.Orders` context.
  """

  @doc """
  Generate a purchase_request.
  """
  def purchase_request_fixture(attrs \\ %{}) do
    buyer = MilkywayApi.AccountsFixtures.user_fixture(%{role: "buyer"})
    product = MilkywayApi.CatalogFixtures.product_fixture()

    {:ok, purchase_request} =
      attrs
      |> Enum.into(%{
        message: "some message",
        status: "pending",
        product_id: product.id,
        buyer_id: buyer.id
      })
      |> MilkywayApi.Orders.create_purchase_request()

    purchase_request
  end

  @doc """
  Generate a basket item.
  """
  def basket_item_fixture(attrs \\ %{}) do
    buyer = MilkywayApi.AccountsFixtures.user_fixture(%{role: "buyer"})
    product = MilkywayApi.CatalogFixtures.product_fixture()

    {:ok, basket_item} =
      attrs
      |> Enum.into(%{product_id: product.id, buyer_id: buyer.id})
      |> MilkywayApi.Orders.add_to_basket()

    basket_item
  end
end
