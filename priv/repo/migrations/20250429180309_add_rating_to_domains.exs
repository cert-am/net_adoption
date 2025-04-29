defmodule NetAdoption.Repo.Migrations.AddRatingToDomains do
  use Ecto.Migration

  def change do
    alter table(:domains) do
      add :rating, :float, default: 0.0
    end
  end
end

