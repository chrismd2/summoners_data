defmodule Summoners.RequestClients.TestRequestClient do
  def request_data("valid_summoner_name", _region) do
    ["summoner_name_1", "summoner_name_2"]
  end

  def request_data(summoner_name, region) when is_binary(summoner_name) do
    if String.valid?(summoner_name) do
      {:error, "summoner_name not found"}
    else
      {:error, request_data(:invalid, region)}
    end
  end

  def request_data(_summoner_name, _region) do
    {:error, "summoner_name is invalid"}
  end
end
