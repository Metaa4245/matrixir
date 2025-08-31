defmodule Matrixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :matrixir,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      {:finch, "~> 0.20"}
    ]
  end
end
