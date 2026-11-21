defmodule MilkywayApi.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:member) do
      add :active, :boolean, default: false, null: false
      add :name, :string
      add :middle_name, :string
      add :last_name, :string
      add :gender, :string
      add :email, :string
      add :phone, :string
      add :generation, :string
      add :birthdate, :date
      add :category, :string
      add :group, :string
      add :jmbg, :string
      add :registration, :date
      add :medical, :date
      add :first_registration, :date
      add :last_registration, :date

      timestamps(type: :utc_datetime)
    end
  end
end
