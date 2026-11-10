defmodule MilkywayApi.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias MilkywayApi.Repo

  alias MilkywayApi.Accounts.User
  alias MilkywayApi.Catalog.Product
  alias MilkywayApi.Orders.BasketItem
  alias MilkywayApi.Orders.PurchaseRequest

  @doc """
  Returns the list of purchase_requests.

  ## Examples

      iex> list_purchase_requests()
      [%PurchaseRequest{}, ...]

  """
  def list_purchase_requests do
    Repo.all(PurchaseRequest)
  end

  @doc """
  Gets a single purchase_request.

  Raises `Ecto.NoResultsError` if the Purchase request does not exist.

  ## Examples

      iex> get_purchase_request!(123)
      %PurchaseRequest{}

      iex> get_purchase_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_purchase_request!(id), do: Repo.get!(PurchaseRequest, id)

  @doc """
  Creates a purchase_request.

  ## Examples

      iex> create_purchase_request(%{field: value})
      {:ok, %PurchaseRequest{}}

      iex> create_purchase_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_purchase_request(attrs) do
    %PurchaseRequest{}
    |> PurchaseRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a purchase_request.

  ## Examples

      iex> update_purchase_request(purchase_request, %{field: new_value})
      {:ok, %PurchaseRequest{}}

      iex> update_purchase_request(purchase_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_purchase_request(%PurchaseRequest{} = purchase_request, attrs) do
    purchase_request
    |> PurchaseRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a purchase_request.

  ## Examples

      iex> delete_purchase_request(purchase_request)
      {:ok, %PurchaseRequest{}}

      iex> delete_purchase_request(purchase_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_purchase_request(%PurchaseRequest{} = purchase_request) do
    Repo.delete(purchase_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking purchase_request changes.

  ## Examples

      iex> change_purchase_request(purchase_request)
      %Ecto.Changeset{data: %PurchaseRequest{}}

  """
  def change_purchase_request(%PurchaseRequest{} = purchase_request, attrs \\ %{}) do
    PurchaseRequest.changeset(purchase_request, attrs)
  end

  @doc """
  Adds a product to a buyer basket.
  """
  def add_to_basket(attrs) do
    %BasketItem{}
    |> BasketItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns buyer basket items with products preloaded.
  """
  def list_basket_items_for_buyer(buyer_id) do
    BasketItem
    |> where([basket_item], basket_item.buyer_id == ^buyer_id)
    |> preload([:product])
    |> Repo.all()
  end

  @doc """
  Returns all basket items with their products preloaded.
  """
  def list_basket_items do
    BasketItem
    |> preload([:product])
    |> Repo.all()
  end

  @doc """
  Returns buyers who added a product to basket.
  """
  def list_buyers_for_product(product_id) do
    User
    |> join(:inner, [user], basket_item in BasketItem, on: basket_item.buyer_id == user.id)
    |> where([_user, basket_item], basket_item.product_id == ^product_id)
    |> distinct(true)
    |> Repo.all()
  end

  @doc """
  Returns products in buyer basket.
  """
  def list_basket_products_for_buyer(buyer_id) do
    Product
    |> join(:inner, [product], basket_item in BasketItem,
      on: basket_item.product_id == product.id
    )
    |> where([_product, basket_item], basket_item.buyer_id == ^buyer_id)
    |> Repo.all()
  end

  @doc """
  Gets a single basket item.

  Raises `Ecto.NoResultsError` if the basket item does not exist.
  """
  def get_basket_item!(id), do: Repo.get!(BasketItem, id)

  @doc """
  Gets a single basket item.

  Returns nil if the basket item does not exist.
  """
  def get_basket_item(id), do: Repo.get(BasketItem, id)

  @doc """
  Deletes a basket item.
  """
  def delete_basket_item(%BasketItem{} = basket_item) do
    Repo.delete(basket_item)
  end
end
