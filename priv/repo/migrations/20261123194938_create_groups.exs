defmodule MilkywayApi.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:groups) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    flush()
    execute "SELECT id, name, inserted_at, updated_at FROM groups LIMIT 0"
  end

  def down do
    raise "This migration cannot safely drop a groups table that may have existed beforehand"
  end
end
