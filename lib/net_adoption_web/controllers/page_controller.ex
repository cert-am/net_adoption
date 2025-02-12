defmodule NetAdoptionWeb.PageController do
  use NetAdoptionWeb, :controller

  import Ecto.Query, only: [where: 3]

  alias NetAdoption.Repo
  alias NetAdoption.Organization

  def home(conn, _params) do
    organizations =
      Repo.all(Organization)
      |> Repo.preload(:domains)
      |> Enum.group_by(& &1.category)

    user_ip = get_user_ip(conn)

    conn
    |> render(:home,
      organizations_by_category: organizations,
      ipv4: user_ip.ipv4,
      ipv6: user_ip.ipv6
    )
  end

  defp get_user_ip(conn) do
    ip_string = conn.remote_ip |> :inet.ntoa() |> to_string()

    cond do
      String.contains?(ip_string, ":") -> %{ipv4: nil, ipv6: ip_string}  # IPv6 detected
      true -> %{ipv4: ip_string, ipv6: nil}  # IPv4 detected
    end
  end

  # TODO: add pattern matching when domain is empty
  def check(conn, params) do
    # TODO: Add a case where we check if the domain is empty
    {:ok, domain} = NetAdoption.check_domain(params["domain"])

    conn
    |> assign(:domain, params["domain"])
    |> assign(:dnssec_result, domain.dnssec)
    |> assign(:ipv4_result, domain.ipv4)
    |> assign(:ipv6_result, domain.ipv6)
    |> assign(:mx_result, domain.mx)
    |> assign(:tls_result, domain.tls)
    |> assign(:http_redirect_to_https, domain.http_redirect_to_https)
    |> assign(:domain, domain.name)
    |> put_resp_header("HX-Push-Url", "/check/" <> URI.encode(params["domain"]))
    |> render(:check)
  end

  def about(conn, _params) do
    conn
    |> render(:about)
  end

  def show_category(conn, %{"category" => category}) do
    organizations =
      Organization
      |> where([o], o.category == ^category)
      |> Repo.all()
      |> Repo.preload(:domains)

    render(conn, :show_category, organizations: organizations, category: category, rating: 5)
  end
end
