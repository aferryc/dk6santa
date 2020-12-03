defmodule Dk6santa.Repo.Migrations.AddSantaIdToContact do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      add(:santa_id, :integer, null: true)
    end

    create(index(:contacts, [:santa_id]))
  end
end
