defmodule SummonersTest do
  use ExUnit.Case
  doctest Summoners

  describe "summoners tests" do
    test "gets summoners data and checks that monitored summoners are the same list" do
      summoner_data = Summoners.fetch_summoner_data("valid_summoner_name")
      assert is_list(summoner_data)
      assert Enum.all?(
        summoner_data,
        fn summoner_name ->
          String.valid?(summoner_name)
        end
      )

      monitored_summoners = Summoners.monitored_summoners()
      |> Enum.map(fn %{summoner_name: summoner_name} -> summoner_name end)
      assert monitored_summoners == summoner_data
    end

    test "invalid name returns error tuple" do
      summoner_data = Summoners.fetch_summoner_data(:invalid)
      assert summoner_data == {:error, "summoner_name is invalid"}
    end

    test "nonexistent name returns error tuple" do
      summoner_data = Summoners.fetch_summoner_data("nonexistent_summoner")
      assert summoner_data == {:error, "summoner_name not found"}
    end
  end
end
