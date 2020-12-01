defmodule Dk6santa.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add(:uuid, :uuid, null: false)
      add(:name, :string, null: false)
      add(:email, :string, null: false)

      timestamps()
    end

    create(index(:contacts, [:email], unique: true))
  end
end
