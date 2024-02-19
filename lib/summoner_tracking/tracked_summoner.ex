defmodule Summoners.SummonerTracking.TrackedSummoner do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(name end_time puuid recent_match_id)a
  @required_fields ~w(name end_time puuid)a

  schema "tracked_summoner" do
    field :name, :string
    field :end_time, :utc_datetime
    field :puuid, Ecto.UUID
    field :recent_match_id, Ecto.UUID
  end

  def changeset(tracked_summoner \\ %__MODULE__{}, params) do
    tracked_summoner
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
