defmodule Summoners.SummonerTracking do
  use Agent

  alias Summoners.SummonerTracking.TrackedSummoner
  alias Task.Supervisor
  alias Summoners.TaskSupervisor

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
    summoner
    |> Map.put(:end_time, DateTime.add(DateTime.utc_now(), @time_to_track.amount, @time_to_track.units))
    |> TrackedSummoner.changeset
    |> add_summoner()
  end

  def add_summoner(_summoner) do
    {:error, "summoner must be a map"}
  end

  def remove(summoner) do
    Agent.update(__MODULE__, &Enum.reject(&1, fn element -> element == summoner end))
  end

  def scheduled_tasks(attempts \\ 3)

  def scheduled_tasks(:stop) do
    Supervisor.children(TaskSupervisor)
    |> Enum.each(&Supervisor.terminate_child(TaskSupervisor, &1))
  end

  def scheduled_tasks(attempts) do
    case Enum.count(Supervisor.children(TaskSupervisor)) do
      0 -> Supervisor.start_child(TaskSupervisor, &scheduled_delete/0)
        {:ok, "started"}
      1 -> {:ok, "running"}
      _ ->
        scheduled_tasks(:stop)
        if attempts > 0 do
          scheduled_tasks(attempts - 1)
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
end
