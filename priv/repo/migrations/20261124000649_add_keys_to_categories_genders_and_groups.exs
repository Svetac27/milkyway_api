defmodule MilkywayApi.Repo.Migrations.AddKeysToCategoriesGendersAndGroups do
  use Ecto.Migration

  def up do
    alter table(:categories) do
      add_if_not_exists :key, :string
    end

    alter table(:genders) do
      add_if_not_exists :key, :string
    end

    alter table(:groups) do
      add_if_not_exists :key, :string
    end
  end

  def down do
    raise "Cannot safely remove key columns that may have existed before this migration"
  end
end
