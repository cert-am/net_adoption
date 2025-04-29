defmodule NetAdoption.Tasks.UpdateDomainRatings do
  alias NetAdoption.{Repo, Domain}

  def run do
    Repo.all(Domain)
    |> Enum.each(fn domain ->
      case NetAdoption.check_domain(domain.domain) do
        {:ok, result} ->
          domain
          |> Domain.changeset(%{rating: result.rating})
          |> Repo.update()

        _ ->
          IO.puts("Skipping domain #{domain.domain}, check failed.")
      end
    end)
  end
end

