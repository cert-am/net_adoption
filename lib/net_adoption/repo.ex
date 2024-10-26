defmodule NetAdoption.Repo do
  use Ecto.Repo,
    otp_app: :net_adoption,
    adapter: Ecto.Adapters.Postgres
end
