defmodule Matrixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :matrixir,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      name: "Matrixir",
      source_url: "https://github.com/Metaa4245/matrixir",
      docs: &docs/0
    ]
  end

  defp docs do
    [
      main: "Matrixir",
      extras: ["README.md"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      {:credo, "~> 1.7", only: :dev, runtime: false, warn_if_outdated: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
      {:finch, "~> 0.20", warn_if_outdated: true}
    ]
  end
end
