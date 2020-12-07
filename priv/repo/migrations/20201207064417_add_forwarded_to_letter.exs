defmodule Dk6santa.Repo.Migrations.AddForwardedToLetter do
  use Ecto.Migration

  def change do
    alter table(:letters) do
      add(:sent, :boolean, default: false)
    end

    drop(index(:letters, [:contact_id, :to_santa]))
    create(index(:letters, [:contact_id, :to_santa, :sent]))
  end
end
