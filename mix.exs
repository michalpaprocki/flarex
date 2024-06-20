defmodule LiveViewFlashCleaner.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_view_flash_cleaner,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        description: "A flash message cleaning package for Phoenix.",
        licenses: ["MIT"],
        links: %{"github" => "https://github.com/michalpaprocki/live_view_flash_cleaner"}]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LiveViewFlashCleaner.Application, [strategy: :one_for_one, name: LiveViewFlashCleaner.Supervisor]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:phoenix_live_view, "~> 0.20"}
    ]
  end
end
