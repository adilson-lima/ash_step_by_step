defmodule AshStepByStep.Repo.Migrations.CreateUserTable do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text
      add :email, :text
    end
  end

  def down do
    drop table(:users)
  end
end