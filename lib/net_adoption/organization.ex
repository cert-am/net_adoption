defmodule NetAdoption.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :category, :string
    has_many :domains, NetAdoption.Domain

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :category])
    |> validate_required([:name, :category])
  end
end
