defmodule MilkywayApi.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MilkywayApi.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, seller} =
      MilkywayApi.Accounts.create_user(%{
        email: "seller-#{System.unique_integer([:positive])}@example.com",
        password: "password123",
        role: "seller"
      })

    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        location: "some location",
        price: 42,
        status: "active",
        title: "some title",
        seller_id: seller.id
      })
      |> MilkywayApi.Catalog.create_product()

    product
  end
end
