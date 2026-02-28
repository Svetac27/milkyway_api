defmodule MilkywayApi.Orders.PurchaseRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "purchase_requests" do
    field :status, :string, default: "pending"
    field :message, :string
    field :product_id, :id
    field :buyer_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(purchase_request, attrs) do
    purchase_request
    |> cast(attrs, [:status, :message, :product_id, :buyer_id])
    |> validate_required([:status, :message, :product_id, :buyer_id])
    |> validate_inclusion(:status, ["pending", "accepted", "rejected", "cancelled"])
  end
end
