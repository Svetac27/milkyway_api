defmodule MilkywayApi.Repo.Migrations.CreateMemberData do
  use Ecto.Migration

  def change do
    create table(:member_data) do
      add :name, :string
      add :key, :string
      add :type, :string
      add :hide, :boolean, default: false, null: false
      add :order, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
