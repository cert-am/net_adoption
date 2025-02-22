defmodule NetAdoption do
  @moduledoc """
  NetAdoption keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API, or others.
  """

  def check_domain(domain) do
    encoded_domain = :idna.encode(domain)

    {
      :ok,
      %{
        name: domain,
        ipv4: check_ipv4(encoded_domain),
        ipv6: check_ipv6(encoded_domain),
        mx: check_mx_records(encoded_domain),
        tls: check_tls(domain),
        http_redirect_to_https: check_http_redirect_to_https(domain),
        dnssec: check_dnssec(encoded_domain)
      }
    }
  end

  defp check_tls(domain) do
    url = "https://" <> domain

    case :httpc.request(:head, {to_charlist(url), []}, [{:timeout, 5000}], []) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp check_http_redirect_to_https(domain) do
    url = "http://" <> domain

    case :httpc.request(:get, {to_charlist(url), []}, [{:timeout, 5000}, {:autoredirect, false}], []) do
      {:ok, {{_, status_code, _}, headers, _}} when status_code in [301, 302] ->
        case List.keyfind(headers, 'location', 0) do
          {'location', location} -> String.starts_with?(to_string(location), "https://")
          _ -> false
        end
      _ -> false
    end
  end

  defp check_dnssec(domain), do: has_dnssec?(domain)

  defp has_dnssec?(domain) do
    case DNS.query(domain, :soa, edns: 0, dnssec_ok: true) do
      {:ok, res} -> Enum.any?(res.anlist, &(&1.type == 46))
      {:error, :nxdomain} -> "No such domain"
    end
  end

  defp check_ipv6(domain), do: has_ipv6?(domain)

  defp has_ipv6?(domain) do
    case DNS.query(domain, :aaaa, edns: 0, dnssec_ok: true) do
      {:ok, res} -> extract_ipv6(res.anlist)
      {:error, :nxdomain} -> "No such domain"
    end
  end

  defp extract_ipv6(anlist) do
    case Enum.filter(anlist, &(&1.type == :aaaa)) do
      [] -> "No AAAA records"
      records -> Enum.map(records, &to_hex_ipv6(&1.data))
    end
  end

  defp to_hex_ipv6({a, b, c, d, e, f, g, h}) do
    [a, b, c, d, e, f, g, h] |> Enum.map(&Integer.to_string(&1, 16)) |> Enum.join(":")
  end

  def check_ipv4(domain), do: has_ipv4?(domain)

  def has_ipv4?(domain) do
    case DNS.query(domain, :a, edns: 0, dnssec_ok: true) do
      {:ok, res} -> extract_ipv4(res.anlist)
      {:error, :nxdomain} -> "No such domain"
    end
  end

  defp extract_ipv4(anlist) do
    case Enum.filter(anlist, &(&1.type == :a)) do
      [] -> "No A records"
      records -> Enum.map(records, &to_dot_decimal_ipv4(&1.data))
    end
  end

  defp to_dot_decimal_ipv4({a, b, c, d}) do
    [a, b, c, d] |> Enum.map(&Integer.to_string/1) |> Enum.join(".")
  end

  defp check_mx_records(domain) do
    case DNS.query(domain, :mx) do
      {:ok, res} -> extract_mx(res.anlist)
      {:error, :nxdomain} -> "No such domain"
    end
  end

  defp extract_mx(anlist) do
    anlist
    |> Enum.filter(&(&1.type == :mx))
    |> Enum.map(fn %{data: {preference, exchange}} -> {preference, to_string(exchange)} end)
    |> Enum.sort_by(fn {preference, _} -> preference end)
    |> Enum.map(fn {preference, exchange} -> "Priority: #{preference}  →  #{exchange}" end)
    |> Enum.join("\n")
  end

end
