defmodule Summoners do
  @moduledoc """
  Documentation for `Summoners`.
  """

  @doc """
  Get a list of summoner names a valid summoner has used for 5 matches and track those summoner names for 1 Hour using a long polling strategy every 1 minute(s)

  ## Examples

      iex> Summoners.fetch_summoner_data("valid_summoner_name")
      ["summoner_name_1", "summoner_name_2"]

  ## Errors

      iex> Summoners.fetch_summoner_data("non_existent_summoner")
      {:error, "summoner_name not found"}

      iex> Summoners.fetch_summoner_data(:invalid)
      {:error, "summoner_name is invalid"}

  """
  def fetch_summoner_data(summoner_name) do
    client(Mix.env).request_data(summoner_name)
  end

  defp client(env) do
    case env do
      :test -> Summoners.RequestClients.TestRequestClient
      _ -> Summoners.RequestClients.DevRequestClient
    end
  end
end
