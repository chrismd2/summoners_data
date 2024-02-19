defmodule Summoners do
  alias Summoners.SummonerTracking
  @moduledoc """
  Documentation for `Summoners`.
  """

  @doc """
  Get a list of summoner names a valid summoner has used for 5 matches and track those summoner names for 1 Hour using a long polling strategy every 1 minute(s)

  ## Examples

      iex> Summoners.find_and_track_associated_summoners("valid_summoner_name", "na1")
      ["summoner_name_1", "summoner_name_2"]

  ## Errors

      iex> Summoners.find_and_track_associated_summoners("non_existent_summoner", "na1")
      {:error, "summoner_name not found"}

      iex> Summoners.find_and_track_associated_summoners(:invalid, "na1")
      {:error, "summoner_name is invalid"}

  """
  def find_and_track_associated_summoners(summoner_name, region) do
    recent_summoners = client(Mix.env).request_associated_summoners(summoner_name, region)

    {:ok, _} = SummonerTracking.scheduled_tasks()

    if is_list(recent_summoners) do
      recent_summoners
      |> Enum.take(5)
      |> Enum.uniq()
    else
      recent_summoners
    end
  end

  defp client(env) do
    case env do
      :test -> Summoners.RequestClients.TestRequestClient
      _ -> Summoners.RequestClients.DevRequestClient
    end
  end

  def start(_, _) do
    children = [
      {Finch, name: Summoners.Finch},
      SummonerTracking,
      {Task.Supervisor, name: Summoners.TaskSupervisor}
    ]
    opts = [strategy: :one_for_one, name: Summoners.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
