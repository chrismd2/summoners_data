# Summoners

**TODO: Add description**

## What's need to run
Environment variables are needed.  Before using `source .env` or on other appropriate file with keys updated in `.env.example`.

This monitors summoners associated with a given summoner logging the game ids they play for a match for an hour.  Can run and start monitoring by calling `Summoners.find_and_track_associated_summoners(summoner_of_interest, region)`.  Regions can be one of:
```
  BR1 EUN1 EUW1
  JP1 KR LA1
  LA2 NA1 OC1
  PH2 RU SG2
  TH2 TR1 TW2
  VN2
```

After having started tracking `Summoners.monitored_summoners()` may be used to view a list of those summoners being tracked and some data related to them.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `summoners` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:summoners, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/summoners>.

