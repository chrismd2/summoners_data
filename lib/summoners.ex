defmodule Summoners do
  alias Summoners.SummonerTracking
  alias Summoners.RequestClients.Client
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
    recent_summoners = Client.selected_client(Mix.env).request_associated_summoners(summoner_name, region)

    {:ok, _} = SummonerTracking.scheduled_tasks()

    if is_list(recent_summoners) do
      summoners = recent_summoners
      |> Enum.map(fn %{summoner_name: summoner_name, puuid: puuid} -> %{name: summoner_name, puuid: puuid} end)
      |> Enum.take(5)
      |> Enum.uniq()

      :ok = Enum.each(summoners, &SummonerTracking.add_summoner(%{name: &1.name, puuid: &1.puuid}))

      Enum.map(summoners, fn %{name: summoner_name} -> summoner_name end)
    else
      recent_summoners
    end
  end

  # @doc """
  # Get monitored summoners

  # ## Examples

  #     iex> Summoners.monitored_summoners()
  #     [
  #       %{
  #         name: "summoner_name_1",
  #         end_date: ~U[2024-02-19 02:24:01.512197Z]
  #       },
  #       %{
  #         name: "summoner_name_2",
  #         end_date: ~U[2024-02-19 02:24:01.512197Z]
  #       }
  #     ]

  # """
  def monitored_summoners() do
    SummonerTracking.monitored_summoners
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
