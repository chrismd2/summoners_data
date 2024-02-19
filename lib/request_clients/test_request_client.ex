defmodule Summoners.RequestClients.TestRequestClient do
  @default_names ~w(summoner_name_1 summoner_name_2)

  def request_associated_summoners("valid_summoner_name", _region) do
    @default_names
    |> Enum.map(& %{
      summoner_name: &1,
      puuid: &1 == "summoner_name_1" && "0583cb35-80be-40a6-8c2f-adca6f608044" || "cde32716-28c1-44e8-8f27-096895e1e372"
    })
  end

  def request_associated_summoners(summoner_name, region) when is_binary(summoner_name) do
    if String.valid?(summoner_name) do
      {:error, "summoner_name not found"}
    else
      {:error, request_associated_summoners(:invalid, region)}
    end
  end

  def request_associated_summoners(_summoner_name, _region) do
    {:error, "summoner_name is invalid"}
  end
end
