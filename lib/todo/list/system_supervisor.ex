
defmodule Todo.List.SystemSupervisor do
  @moduledoc false

  use Supervisor
  use RegHelper

  alias Todo.List.Cache
  alias Todo.List.ServerSupervisor

  @mod __MODULE__

  ###   C L I E N T   I N T E R F A C E

  @spec start_link :: Supervisor.on_start
  def start_link do
    log_start Supervisor.start_link(@mod, :ok, name: name())
  end

  ###   S U P E R V I S O R   C A L L B A C K S

  @spec init(term) :: {:ok, {:supervisor.sup_flags, [Supervisor.Spec.spec]}}
  def init(:ok) do
    log_init()
    children = [
      supervisor(ServerSupervisor, []),
      worker(Cache, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
