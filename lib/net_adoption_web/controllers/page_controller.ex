defmodule NetAdoptionWeb.PageController do
  use NetAdoptionWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home)
  end

  # TODO: add pattern matching when domain is empty
  def check(conn, params) do
    # TODO: Add a case where we check if the domain is empty
    dnssec_res = NetAdoption.check_dnssec(params["domain"])
    ipv6_res   = NetAdoption.check_ipv6(params["domain"])
    conn
    |> assign(:dnssec_result, dnssec_res)
    |> assign(:ipv6_result,   ipv6_res)
    |> assign(:domain,        params["domain"])
    |> put_resp_header("HX-Push-Url", "/check/" <> URI.encode(params["domain"]))
    |> render(:check)
  end

  def about(conn, _params) do
    conn
    |> render(:about)
  end
end
