defmodule NetAdoptionWeb.PageController do
  use NetAdoptionWeb, :controller

  alias NetAdoption.Repo
  alias NetAdoption.Organization

  def home(conn, _params) do
    organizations =
      Repo.all(Organization)
      |> Repo.preload(:domains)
      |> Enum.group_by(& &1.category)

    conn
    |> render(:home, organizations_by_category: organizations)
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
    |> assign(:domain, domain.name)
    |> put_resp_header("HX-Push-Url", "/check/" <> URI.encode(params["domain"]))
    |> render(:check)
  end

  def about(conn, _params) do
    conn
    |> render(:about)
  end
end
