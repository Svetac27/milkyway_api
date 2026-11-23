defmodule MilkywayApi.Repo.Migrations.RenameMemberToMembers do
  use Ecto.Migration

  def up do
    execute """
    DO $$
    BEGIN
      IF to_regclass('member') IS NOT NULL AND to_regclass('members') IS NOT NULL THEN
        RAISE EXCEPTION 'Both member and members tables exist; resolve the conflict before migrating';
      ELSIF to_regclass('member') IS NOT NULL THEN
        ALTER TABLE member RENAME TO members;
      ELSIF to_regclass('members') IS NULL THEN
        RAISE EXCEPTION 'Neither member nor members table exists';
      END IF;
    END
    $$;
    """
  end

  def down do
    raise "This migration cannot safely restore a table name that may have been changed beforehand"
  end
end
