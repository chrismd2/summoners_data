defmodule Summoners do
  @moduledoc """
  Documentation for `Summoners`.
  """

  @doc """
  Get a list of summoner names a valid summoner has used for 5 matches and track those summoner names for 1 Hour using a long polling strategy every 1 minute(s)

  ## Examples

      iex> Summoners.fetch_summoner_data("valid_summoner_name", "na1")
      ["summoner_name_1", "summoner_name_2"]

  ## Errors

      iex> Summoners.fetch_summoner_data("non_existent_summoner", "na1")
      {:error, "summoner_name not found"}

      iex> Summoners.fetch_summoner_data(:invalid, "na1")
      {:error, "summoner_name is invalid"}

  """
  def fetch_summoner_data(summoner_name, region) do
    client(Mix.env).request_data(summoner_name, region)
  end

  defp client(env) do
    case env do
      :test -> Summoners.RequestClients.TestRequestClient
      _ -> Summoners.RequestClients.DevRequestClient
    end
  end

  def start(_, _) do
    children = [{Finch, name: Summoners.Finch}]
    opts = [strategy: :one_for_one, name: Summoners.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
