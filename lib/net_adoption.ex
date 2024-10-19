defmodule NetAdoption do
  @moduledoc """
  NetAdoption keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # TODO: this function should return all the data that we need.
  # def check_domain(domain) do
  #  {:error, "put error here"}
  #  OR
  #  {:ok,
  #    %{
  #      ipv4: [],
  #      mx: [],
  #      tls: true,
  #      ipv6: [],
  #      dnssec: true
  #    }
  #  }
  # end

  def check_domain(domain) do
    ipv4 = check_ipv4(domain)
    ipv6 = check_ipv6(domain)
    mx = "MX"
    tls = "TLS"
    dnssec = check_dnssec(domain)

    {
      :ok,
      %{
        name: domain,
        ipv4: ipv4,
        ipv6: ipv6,
        mx: mx,
        tls: tls,
        dnssec: dnssec
      }
    }
  end

  defp check_dnssec(domain) do
    domain
    |> :idna.encode()
    |> has_dnssec?
    |> inspect(limit: :infinity, pretty: true)
  end

  defp has_dnssec?(domain) do
    case DNS.query(domain, :soa, edns: 0, dnssec_ok: true) do
      {:ok, res} ->
        res
        |> Map.get(:anlist)
        |> Enum.any?(fn x -> x.type == 46 end)

      {:error, :nxdomain} ->
        "No such domain"
    end
  end

  defp check_ipv6(domain) do
    domain
    |> :idna.encode()
    |> has_ipv6?
    |> inspect(limit: :infinity, pretty: true)
  end

  defp has_ipv6?(domain) do
    case DNS.query(domain, :aaaa, edns: 0, dnssec_ok: true) do
      {:ok, res} ->
        res
        |> Map.get(:anlist)
        |> get_aaaa_rr()

      {:error, :nxdomain} ->
        "No such domain"
    end
  end

  defp get_aaaa_rr(anlist) do
    case length(anlist) do
      0 ->
        "No AAAA records"

      _ ->
        anlist
        |> Enum.filter(fn r -> r.type == :aaaa end)
        |> Enum.map(fn r -> to_hex_ipv6(r.data) end)
    end
  end

  defp to_hex_ipv6({a, b, c, d, e, f, g, h}) do
    [a, b, c, d, e, f, g, h]
    |> Enum.map(fn x -> Integer.to_string(x, 16) end)
    |> Enum.join(":")
  end

  def check_ipv4(domain) do
    domain
    |> :idna.encode()
    |> has_ipv4?
    |> inspect(limit: :infinity, pretty: true)
  end

  def has_ipv4?(domain) do
    case DNS.query(domain, :a, edns: 0, dnssec_ok: true) do
      {:ok, res} ->
        res
        |> Map.get(:anlist)
        |> get_a_rr()

      {:error, :nxdomain} ->
        "No such domain"
    end
  end

  defp get_a_rr(anlist) do
    case length(anlist) do
      0 ->
        "No A records"

      _ ->
        anlist
        |> Enum.filter(fn r -> r.type == :a end)
        |> Enum.map(fn r -> to_dot_decimal_ipv4(r.data) end)
    end
  end

  defp to_dot_decimal_ipv4({a, b, c, d}) do
    [a, b, c, d]
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(".")
  end
end
