defmodule Summoners.MixProject do
  use Mix.Project

  def project do
    [
      app: :summoners,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Summoners, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.11.1"},
      {:finch, "~> 0.18.0"},
      {:jason, "~> 1.4.1"}
    ]
  end
end
