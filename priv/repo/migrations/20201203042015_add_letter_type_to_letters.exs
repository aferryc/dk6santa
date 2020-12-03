defmodule Dk6santa.Repo.Migrations.AddToSantaToLetters do
  use Ecto.Migration

  def change do
    alter table(:letters) do
      add(:to_santa, :boolean, default: true)
    end

    drop(index(:letters, [:contact_id]))
    create(index(:letters, [:contact_id, :to_santa]))
  end
end
