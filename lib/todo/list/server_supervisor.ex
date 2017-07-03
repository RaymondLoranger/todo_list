
defmodule Todo.List.ServerSupervisor do
  @moduledoc false

  use Supervisor
  use RegHelper

  alias Todo.List.Server

  @mod __MODULE__

  ###   C L I E N T   I N T E R F A C E

  @spec start_link :: Supervisor.on_start
  def start_link do
    log_start Supervisor.start_link(@mod, :ok, name: name())
  end

  @spec start_child(List.name) :: Supervisor.on_start_child
  def start_child(list_name) do
    Supervisor.start_child(name(), [list_name])
  end

  ###   S U P E R V I S O R   C A L L B A C K S

  @spec init(:ok) :: {:ok, {:supervisor.sup_flags, [Supervisor.Spec.spec]}}
  def init(:ok) do
    log_init()
    children = [
      worker(Server, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
