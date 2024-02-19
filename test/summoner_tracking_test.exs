defmodule SummonerTrackingTest do
  use ExUnit.Case
  alias Summoners.SummonerTracking

  describe "summoner tracking testing" do
    test "summoner play data returns a match id and saves it in recent games for tracking" do
      match_ids = SummonerTracking.scheduled_update_check([summoner_monitor_time: 1])
      assert Enum.sort(match_ids) == SummonerTracking.monitored_summoners()
      |> Enum.map(&Map.get(&1, :recent_match_id))
      |> Enum.sort()
    end
  end
end
