defmodule MilkywayApi.Repo.Migrations.CreatePurchaseRequests do
  use Ecto.Migration

  def change do
    create table(:purchase_requests) do
      add :status, :string
      add :message, :text
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :buyer_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:purchase_requests, [:product_id])
    create index(:purchase_requests, [:buyer_id])
    create unique_index(:purchase_requests, [:product_id, :buyer_id])
  end
end
