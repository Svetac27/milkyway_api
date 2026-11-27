defmodule MilkywayApi.Repo.Migrations.AddActiveAndImageToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :active, :boolean, default: true
      add :image, :text, null: true
    end
  end
end
