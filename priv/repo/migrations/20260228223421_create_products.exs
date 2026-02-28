defmodule MilkywayApi.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string
      add :description, :text
      add :price, :integer
      add :status, :string
      add :location, :string
      add :seller_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:seller_id])
    create index(:products, [:status])
  end
end
