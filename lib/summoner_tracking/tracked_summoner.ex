defmodule Summoners.SummonerTracking.TrackedSummoner do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(name end_time)a

  schema "tracked_summoner" do
    field :name, :string
    field :end_time, :utc_datetime
  end

  def changeset(tracked_summoner \\ %__MODULE__{}, params) do
    tracked_summoner
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
