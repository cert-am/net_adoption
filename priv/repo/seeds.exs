alias NetAdoption.Repo
alias NetAdoption.Organization
alias NetAdoption.Domain
require Logger

defmodule CSVImporter do
  @csv_file "priv/repo/organizations.csv"

  def import do
    @csv_file
    |> File.stream!()
    |> Stream.each(&process_line/1)
    |> Enum.to_list()
  end

  defp process_line(line) do
    [name, category, domain_name | _] = String.split(line, ",")
    category = String.trim(category)

    # Insert organization
    case Repo.insert(%Organization{name: String.trim(name), category: category}) do
      {:ok, organization} ->
        Logger.info("Inserted organization: #{organization.name}")
        insert_domain(organization.id, String.trim(domain_name))

      {:error, changeset} ->
        Logger.error("Failed to insert organization: #{inspect(changeset.errors)}")
    end
  end

  defp insert_domain(organization_id, domain_name) when domain_name != "-" do
    Repo.insert(%Domain{organization_id: organization_id, domain: domain_name})
    |> case do
      {:ok, _} -> Logger.info("Inserted domain for organization_id #{organization_id}: #{domain_name}")
      {:error, changeset} -> Logger.error("Failed to insert domain: #{inspect(changeset.errors)}")
    end
  end

  defp insert_domain(_, _), do: :ok  # Skip empty domain names
end

# Call the import function
CSVImporter.import()

