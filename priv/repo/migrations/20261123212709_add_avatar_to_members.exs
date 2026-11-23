defmodule MilkywayApi.Repo.Migrations.AddAvatarToMembers do
  use Ecto.Migration

  def up do
    alter table(:members) do
      add_if_not_exists :avatar, :string
    end
  end

  def down do
    raise "Cannot safely remove an avatar column that may have existed before this migration"
  end
end
