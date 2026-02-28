defmodule MilkywayApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :role, :string, null: false, default: "buyer"
      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:role])
  end
end
