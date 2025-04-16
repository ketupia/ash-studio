defmodule AshStudio.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_studio,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      description: "AI development tools for the Ash Framework.",
      source_url: "https://github.com/ketupia/ash_studio",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ash, "~> 3.0"},
      {:ash_ai, "~> 0.1", github: "ash-project/ash_ai"},
      {:ash_phoenix, "~> 2.0"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:gettext, "~> 0.26 and >= 0.26.1"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:jason, "~> 1.2"},
      # {:mcp_sse, "~> 0.1"},
      # {:open_api_spex, "~> 3.0"},
      {:phoenix, "~> 1.7.21"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:picosat_elixir, "~> 0.2"},
      # {:redoc_ui_plug, "~> 0.2"},
      {:sourceror, "~> 1.7", only: [:dev, :test]},
      {:telemetry_metrics, "~> 1.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Kevin Bolton"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ketupia/ash_studio"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test"],
      "test.setup": ["ash.setup --quiet", "test"],
      "test.with_coverage": ["coveralls.html", "test"]
    ]
  end
end
