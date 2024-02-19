defmodule Summoners.RequestClients.Client do
  def selected_client(env \\ Mix.env()) do
    case env do
      :test -> Summoners.RequestClients.TestRequestClient
      _ -> Summoners.RequestClients.DevRequestClient
    end
  end
end
