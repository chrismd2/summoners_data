defmodule Summoners.SummonerTracking do
  use Agent

  alias Summoners.SummonerTracking.TrackedSummoner
  alias Summoners.RequestClients.Client
  alias Task.Supervisor
  alias Summoners.TaskSupervisor

  require Logger

  @time_to_track %{amount: 1, units: :hour}

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__, id: :summoner_tracking)
  end

  def monitored_summoners() do
    Agent.get(__MODULE__, & &1)
  end

  def add_summoner(%{changes: summoner, valid?: true}) do
    Agent.update(__MODULE__, &(&1 ++ [summoner]))
  end

  def add_summoner(%{errors: errors}) do
    {:error, errors}
  end

  def add_summoner(summoner) when is_map(summoner) do
    monitored_summoners()
    |> Enum.filter(& &1.puuid == summoner.puuid)
    |> Enum.each(&remove/1)

    summoner
    |> Map.put(:end_time, DateTime.add(DateTime.utc_now(), @time_to_track.amount, @time_to_track.units))
    |> TrackedSummoner.changeset
    |> add_summoner()
  end

  def add_summoner(_summoner) do
    {:error, "summoner must be a map"}
  end

  def update(%{changes: summoner, valid?: true}) do
    new_list = monitored_summoners()
    |> Enum.reject(& &1.puuid == summoner.puuid)
    Agent.update(__MODULE__, fn _ ->[summoner | new_list] end)
  end

  def update(%{errors: errors}) do
    {:error, errors}
  end

  def update(summoner) when is_map(summoner) do
    summoner
    |> Map.put(:end_time, DateTime.add(DateTime.utc_now(), @time_to_track.amount, @time_to_track.units))
    |> TrackedSummoner.changeset
    |> update()
  end

  def update(_summoner) do
    {:error, "summoner must be a map"}
  end

  def remove(summoner) do
    Agent.update(__MODULE__, &Enum.reject(&1, fn element -> element == summoner end))
  end

  def scheduled_tasks(attempts \\ 3, opts \\ [])

  def scheduled_tasks(:stop, _) do
    Supervisor.children(TaskSupervisor)
    |> Enum.each(&Supervisor.terminate_child(TaskSupervisor, &1))
  end

  def scheduled_tasks(attempts, opts) do
    case Enum.count(Supervisor.children(TaskSupervisor)) do
      0 ->
        Supervisor.start_child(TaskSupervisor, &scheduled_delete/0)
        Supervisor.start_child(TaskSupervisor, &scheduled_update_check/0)
        {:ok, "started"}
      2 -> {:ok, "running"}
      _ ->
        scheduled_tasks(:stop, opts)
        if attempts > 0 do
          scheduled_tasks(attempts - 1, opts)
        else
          {:error, "couldn't start"}
        end
    end
  end

  defp scheduled_delete() do
    :timer.sleep(1_000)

    monitored_summoners()
    |> Enum.map(fn %{end_time: end_time} = summoner -> if DateTime.after?(DateTime.utc_now(), end_time), do: remove(summoner), else: summoner end)

    Agent.cast(__MODULE__, scheduled_delete())
  end

  def scheduled_update_check(opts \\ []) do
    monitored_summoners()
    |> Enum.map(fn %{name: summoner_name, puuid: puuid} = summoner ->
      match_id = Client.selected_client().get_summoner_play_data(puuid, opts[:region] || "na1")
      if summoner[:recent_match_id] != match_id do
        summoner
        |> Map.put(:recent_match_id, match_id)
        |> update()
        Logger.info("Summoner #{summoner_name} completed match #{match_id}")
      end
      match_id
    end)
    :timer.sleep(opts[:summoner_monitor_time] || 60_000)
    Agent.cast(__MODULE__, scheduled_update_check(opts))
  end
end
