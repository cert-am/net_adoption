defmodule NetAdoption.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  schema "domains" do
    field :domain, :string
    belongs_to :organization, NetAdoption.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:domain])
    |> validate_required([:domain])
  end
end
