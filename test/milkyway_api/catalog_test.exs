defmodule MilkywayApi.CatalogTest do
  use MilkywayApi.DataCase

  alias MilkywayApi.Catalog

  describe "products" do
    alias MilkywayApi.Catalog.Product

    alias MilkywayApi.Accounts
    import MilkywayApi.CatalogFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, location: nil, price: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalog.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.get_product!(product.id) == product
    end

    test "create_product/1 with admin seller creates a product" do
      {:ok, seller} =
        Accounts.create_user(%{
          email: "seller-#{System.unique_integer([:positive])}@example.com",
          password: "password123",
          role: "seller"
        })

      valid_attrs = %{
        status: "active",
        description: "some description",
        title: "some title",
        location: "some location",
        price: 42,
        seller_id: seller.id
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.status == "active"
      assert product.description == "some description"
      assert product.title == "some title"
      assert product.location == "some location"
      assert product.price == 42
      assert product.seller_id == seller.id
    end

    test "create_product/1 with valid data creates a product" do
      {:ok, admin} =
        Accounts.create_user(%{
          email: "admin-#{System.unique_integer([:positive])}@example.com",
          password: "password123",
          role: "admin"
        })

      valid_attrs = %{
        status: "active",
        description: "some description",
        title: "some title",
        location: "some location",
        price: 42,
        seller_id: admin.id
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.status == "active"
      assert product.description == "some description"
      assert product.title == "some title"
      assert product.location == "some location"
      assert product.price == 42
      assert product.seller_id == admin.id
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        status: "reserved",
        description: "some updated description",
        title: "some updated title",
        location: "some updated location",
        price: 43
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.status == "reserved"
      assert product.description == "some updated description"
      assert product.title == "some updated title"
      assert product.location == "some updated location"
      assert product.price == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert product == Catalog.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end
end
