defmodule Transmute.MixProject do
  use Mix.Project

  def project() do
    [
      app: :transmute,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        test_all: :test
      ],
      dialyzer: [flags: [:underspecs, :unmatched_returns]]
    ]
  end

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps() do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.8", only: [:dev], runtime: false}
    ]
  end

  defp aliases() do
    [
      test_all: ["format --check-formatted", "credo", "test", "dialyzer"]
    ]
  end
end
