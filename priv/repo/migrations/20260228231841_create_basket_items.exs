defmodule MilkywayApi.Repo.Migrations.CreateBasketItems do
  use Ecto.Migration

  def change do
    create table(:basket_items) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :buyer_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:basket_items, [:product_id])
    create index(:basket_items, [:buyer_id])
    create unique_index(:basket_items, [:product_id, :buyer_id])
  end
end
