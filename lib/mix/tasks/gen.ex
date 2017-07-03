
defmodule Mix.Tasks.Gen do
  @moduledoc false

  # use Mix.Task # otherwise dialyzer complains

  def run(_args) do
    Mix.Tasks.Cmd.run ~w/mix compile/
    # Mix.Tasks.Cmd.run ~w/mix test --no-start/ # fails on_exit
    Mix.Tasks.Cmd.run ~w/mix test/
    Mix.Tasks.Cmd.run ~w/mix dialyzer/
    Mix.Tasks.Cmd.run ~w/mix docs/
  end
end
