defmodule NetAdoptionWeb.PageController do
  use NetAdoptionWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home)
  end

  def check(conn, params) do
    dnssec_res = NetAdoption.check_dnssec(params["domain"])
    ipv6_res   = NetAdoption.check_ipv6(params["domain"])
    conn
    |> assign(:dnssec_result, dnssec_res)
    |> assign(:ipv6_result,   ipv6_res)
    |> render(:check)
  end
end
