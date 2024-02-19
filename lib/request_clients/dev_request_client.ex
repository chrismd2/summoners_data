defmodule Summoners.RequestClients.DevRequestClient do
  @base_url "api.riotgames.com"
  @valid_regions ~w(
    BR1 EUN1 EUW1
    JP1 KR LA1
    LA2 NA1 OC1
    PH2 RU SG2
    TH2 TR1 TW2
    VN2
  )

  require Logger

  def request_associated_summoners(summoner_name, region) when is_binary(summoner_name) do
    with {"valid_name", true} <- {"valid_name", String.valid?(summoner_name)},
       url <- url(region) <> "/lol/summoner/v4/summoners/by-name/#{summoner_name}",
       {"valid_url", true, _url} <- {"valid_url", !is_tuple(url), url},
       %{
          status: _,
          body: body
        } <- Finch.build(:get, url, request_headers())
               |> Finch.request!(Summoners.Finch),
        %{id: encrypted_id} <- Jason.decode!(body) do
      Finch.build(:get, url(region) <> "/lol/league/v4/entries/by-summoner/#{encrypted_id}")
      |> Finch.request!(Summoners.Finch)
      |> Map.get(:body)
      |> Jason.decode!()
    else
      {"valid_name", false} -> {:error, request_associated_summoners(:invalid, region)}
      {"valid_url", false, {:error, message}} -> {:error, message}
      %{status: 404} -> {:error, "summoner_name not found"}
      %{status: 401} -> {:error, "unauthorized"}
      error ->
        Logger.error("unknown error requesting data for summoner \"#{summoner_name}\" in region \"#{region}\".
                    Recieved #{inspect(error)}")
        {:error, "unknown error"}
    end
  end

  def request_associated_summoners(_summoner_name, _region) do
    {:error, "summoner_name is invalid"}
  end

  defp key() do
    System.get_env("RIOT_KEY")
  end

  defp request_headers do
    [{"Authorization", "Bearer #{key()}"}]
  end

  defp url(region) when region in @valid_regions do
    "https://#{String.downcase(region)}.#{@base_url}"
  end

  defp url(region) when is_binary(region) do
    region = String.upcase(region)
    if region in @valid_regions do
      url(region)
    else
      {:error, "invalid region"}
    end
  end

  def get_summoner_play_data(puuid, region) do
    url = url(region) <> "/lol/match/v5/matches/by-puuid/#{puuid}/ids?#count=1"
    Finch.build(:get, url, request_headers())
    |> Finch.request!(Summoners.Finch)
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
