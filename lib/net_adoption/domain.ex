defmodule NetAdoption.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  schema "domains" do
    field :domain, :string
    field :rating, :float, default: 0.0
    belongs_to :organization, NetAdoption.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:domain, :rating])
    |> validate_required([:domain])
    |> validate_number(:rating, greater_than_or_equal_to: 0.0)
  end
end

