defmodule SummonersTest do
  use ExUnit.Case
  doctest Summoners

  describe "summoners tests" do
    test "gets summoners data and checks that monitored summoners are the same list" do
      summoner_data = Summoners.find_and_track_associated_summoners("valid_summoner_name", "na1")
      assert is_list(summoner_data)
      assert Enum.all?(
        summoner_data,
        fn summoner_name ->
          String.valid?(summoner_name)
        end
      )

      monitored_summoners = Summoners.monitored_summoners()
      assert summoner_data == monitored_summoners
      |> Enum.map(fn %{name: summoner_name} -> summoner_name end)

      :timer.sleep(1_500)

      Summoners.find_and_track_associated_summoners("valid_summoner_name", "na1")
      [%{end_time: new_time} | _] = Summoners.monitored_summoners()
      assert Enum.all?(monitored_summoners, & !DateTime.after?(&1.end_time, new_time))
    end

    test "invalid name returns error tuple" do
      summoner_data = Summoners.find_and_track_associated_summoners(:invalid, "na1")
      assert summoner_data == {:error, "summoner_name is invalid"}
    end

    test "nonexistent name returns error tuple" do
      summoner_data = Summoners.find_and_track_associated_summoners("nonexistent_summoner", "na1")
      assert summoner_data == {:error, "summoner_name not found"}
    end
  end
end
