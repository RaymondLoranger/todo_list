
defmodule Todo.List.Server do
  @moduledoc false

  use GenServer
  use RegHelper

  alias IO.ANSI.Table.Formatter
  alias IO.ANSI.Table.Style
  alias Todo.List
  alias Todo.List.Entry

  @app   Mix.Project.config[:app]
  @bell  Application.get_env @app, :bell
  @count Application.get_env @app, :default_count
  @mod   __MODULE__

  ###   C L I E N T   I N T E R F A C E

  @spec start_link(List.name) :: GenServer.on_start
  def start_link(list_name) do
    log_start GenServer.start_link(@mod, list_name, name: via(list_name))
  end

  @spec stop(List.name) :: :ok
  def stop(list_name), do: GenServer.stop(via(list_name))

  @spec print_entries(List.name, Style.t) :: :ok
  def print_entries(list_name, style) do
    GenServer.call(via(list_name), {:print_entries, style})
  end

  @spec entries(List.name, Date.t) :: [Entry.t]
  def entries(list_name, %Date{} = date) when is_map(date) do
    GenServer.call(via(list_name), {:entries, date})
  end

  @spec add_entry(List.name, Entry.t) :: :ok
  def add_entry(list_name, %Entry{} = entry) do
    GenServer.cast(via(list_name), {:add_entry, entry})
  end

  @spec add_entries(List.name, [Entry.t]) :: :ok
  def add_entries(list_name, entries) when is_list(entries) do
    GenServer.cast(via(list_name), {:add_entries, entries})
  end

  @spec update_entry(List.name, Entry.t) :: :ok
  def update_entry(list_name, %Entry{} = entry) do
    GenServer.cast(via(list_name), {:update_entry, entry})
  end

  @spec delete_entry(List.name, pos_integer) :: :ok
  def delete_entry(list_name, entry_id) when
    is_integer(entry_id) and entry_id > 0
  do
    GenServer.cast(via(list_name), {:delete_entry, entry_id})
  end

  @spec clear_entries(List.name) :: :ok
  def clear_entries(list_name) do
    GenServer.cast(via(list_name), :clear_entries)
  end

  ###   S E R V E R   C A L L B A C K S

  @spec init(List.name) :: {:ok, List.t}
  def init(list_name) do
    log_init()
    { :ok,
      case restore(list_name) do
        :error -> List.new(list_name)
        {:ok, todo_list} ->
          log_warn "restored #{list_name}"
          todo_list
      end
    }
  end

  @spec handle_call({:print_entries, Style.t}, GenServer.from, List.t) ::
    {:reply, :ok, List.t}
  def handle_call({:print_entries, style}, _from, todo_list) do
    { :reply,
      Formatter.print_table(List.map_entries(todo_list), @count, @bell, style),
      todo_list
    }
  end

  @spec handle_call({:entries, Date.t}, GenServer.from, List.t) ::
    {:reply, [Entry.t], List.t}
  def handle_call({:entries, date}, _from, todo_list) do
    {:reply, List.entries(todo_list, date), todo_list}
  end

  @spec handle_cast({:add_entry, Entry.t}, List.t) :: {:noreply, List.t}
  def handle_cast({:add_entry, entry}, todo_list) do
    noreply List.add_entry(todo_list, entry)
  end

  @spec handle_cast({:add_entries, [Entry.t]}, List.t) :: {:noreply, List.t}
  def handle_cast {:add_entries, entries}, todo_list do
    noreply List.add_entries(todo_list, entries)
  end

  @spec handle_cast({:update_entry, Entry.t}, List.t) :: {:noreply, List.t}
  def handle_cast({:update_entry, entry}, todo_list) do
    noreply List.update_entry(todo_list, entry)
  end

  @spec handle_cast({:delete_entry, pos_integer}, List.t) :: {:noreply, List.t}
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    noreply List.delete_entry(todo_list, entry_id)
  end

  @spec handle_cast(:clear_entries, List.t) :: {:noreply, List.t}
  def handle_cast(:clear_entries, %List{} = todo_list) do
    noreply List.clear_entries(todo_list)
  end

  @spec noreply(List.t) :: {:noreply, List.t}
  defp noreply(%List{name: list_name} = todo_list) do
    log_warn "saving #{list_name}"
    save(list_name, todo_list)
    {:noreply, todo_list}
  end

  # needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}
end
