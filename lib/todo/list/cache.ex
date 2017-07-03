
defmodule Todo.List.Cache do
  @moduledoc false

  use GenServer
  use RegHelper

  alias Todo.List.Server
  alias Todo.List.ServerSupervisor

  @mod __MODULE__

  ###   C L I E N T   I N T E R F A C E

  @spec start_link :: GenServer.on_start
  def start_link do
    log_start GenServer.start_link(@mod, :ok, name: name())
  end

  @spec stop :: :ok
  def stop, do: GenServer.stop(name())

  @spec server_process(List.name) :: pid
  def server_process(list_name) do
    case Server.whereis(list_name) do
      nil -> GenServer.call(name(), {:server_process, list_name})
      pid -> pid
    end
  end

  ###   S E R V E R   C A L L B A C K S

  @spec init(:ok) :: {:ok, nil}
  def init(:ok) do
    log_init()
    {:ok, nil}
  end

  @spec handle_call({:server_process, List.name}, GenServer.from, nil) ::
    {:reply, pid, nil}
  def handle_call({:server_process, list_name}, _from, nil) do
    # we need to recheck if the server exists
    server_pid = case Server.whereis(list_name) do
      nil ->
        {:ok, pid} = ServerSupervisor.start_child(list_name)
        pid
      pid -> pid
    end
    {:reply, server_pid, nil}
  end

  # needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}
end
