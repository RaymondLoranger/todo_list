defmodule Todo.List.Mixfile do
  use Mix.Project

  def project do
    [ app: :todo_list,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      name: "Todo List",
      source_url: source_url(),
      description: description(),
      deps: deps()
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/todo_list"
  end

  defp description do
    """
    To-do List app using the Elixir 1.4 Registry to persist state.
    """
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [ extra_applications: [:logger],
      mod: {Todo.List.Application, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [ {:reg_helper, "~> 0.1"},
      {:io_ansi_table, "~> 0.2"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "== 0.4.4", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.9"}
    ]
  end
end
