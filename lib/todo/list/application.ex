
defmodule Todo.List.Application do
  @moduledoc """
  Starts the to-do list application.
  """

  use Application
  use RegHelper

  alias Todo.List.SystemSupervisor

  ###   A P P L I C A T I O N   C A L L B A C K S

  @spec start(Application.start_type, term) :: {:ok, pid}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised...
    children = [
      supervisor(Registry, [:unique, reg_name()]),
      supervisor(SystemSupervisor, [])
    ]
    case Mix.env do
      :dev  -> Logger.configure(level: :debug) # allow all messages
      :test -> Logger.configure(level: :error) # allow only error messages
      _     -> Logger.configure(level: :warn ) # allow warn/error messages
    end
    opts = [strategy: :rest_for_one, name: name()]
    log_start Supervisor.start_link(children, opts)
  end
end
