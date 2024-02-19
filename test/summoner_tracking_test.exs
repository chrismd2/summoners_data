defmodule SummonerTrackingTest do
  use ExUnit.Case
  alias Summoners.SummonerTracking
  alias Task.Supervisor
  alias Summoners.TaskSupervisor

  describe "summoner tracking testing" do
    test "summoner play data returns a match id and saves it in recent games for tracking" do
      Supervisor.start_child(TaskSupervisor, &scheduled_update_check_test/0)
      :timer.sleep(500)
      assert SummonerTracking.monitored_summoners()
      |> Enum.all?(& !is_nil(&1.recent_match_id))
    end
  end
  defp scheduled_update_check_test() do
    SummonerTracking.scheduled_update_check([summoner_monitor_time: 1])
  end
end
