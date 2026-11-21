defmodule MilkywayApi.Repo.Migrations.CreateGenders do
  use Ecto.Migration

  def change do
    create table(:genders) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
