defmodule Dk6santa.Repo.Migrations.CreateLetters do
  use Ecto.Migration

  def change do
    create table(:letters) do
      add(:html, :text)
      add(:plain, :text)
      add(:subject, :text)
      add(:contact_id, references(:contacts, on_delete: :nothing))

      timestamps()
    end

    create(index(:letters, [:contact_id]))
  end
end
