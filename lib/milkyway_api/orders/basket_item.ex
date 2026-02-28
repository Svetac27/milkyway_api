defmodule MilkywayApi.Orders.BasketItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "basket_items" do
    belongs_to :product, MilkywayApi.Catalog.Product
    belongs_to :buyer, MilkywayApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(basket_item, attrs) do
    basket_item
    |> cast(attrs, [:product_id, :buyer_id])
    |> validate_required([:product_id, :buyer_id])
    |> unique_constraint([:product_id, :buyer_id])
  end
end
