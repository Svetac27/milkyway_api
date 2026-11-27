defmodule MilkywayApi.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :description,
             :price,
             :status,
             :location,
             :active,
             :image,
             :seller_id,
             :inserted_at,
             :updated_at
           ]}

  schema "products" do
    field :title, :string
    field :description, :string
    field :price, :integer
    field :status, :string, default: "active"
    field :location, :string
    field :active, :boolean, default: true
    field :image, :string
    field :seller_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:title, :description, :price, :status, :location, :active, :image])
    |> validate_required([:title, :description, :price, :status, :location, :active, :image])
    |> validate_inclusion(:status, ["active", "reserved", "sold", "hidden"])
  end
end
