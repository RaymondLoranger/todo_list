
defmodule IE do
  @moduledoc false

  use RegHelper

  alias Todo.List.Cache
  alias Todo.List.Entry
  alias Todo.List.Server

  # Functions/macros for iex session...
  #
  # Examples:
  #   require IE
  #   IE.use
  #   :observer.start
  #   Cache.server_process("Bob's list")
  #   Cache.server_process("Kim's list")
  #   Server.add_entry("Kim's list", Elixir.List.last(IE.entries))
  #   Server.print_entries("Kim's list", :pretty_alt)
  #   Server.add_entries("Kim's list", IE.entries)
  #   Server.delete_entry("Kim's list", 6)
  #   Server.print_entries("Kim's list", :pretty_alt)
  #   Server.whereis("Kim's list")
  #   Server.whereis("Who's list")
  #   IE.kill_server("Kim's list")
  #   Cache.server_process("Kim's list")
  #   Server.whereis("Kim's list")
  #   Server.print_entries("Kim's list", :pretty_alt)
  #   IE.kill_cache
  #   Cache.whereis
  #   Server.whereis("Kim's list")
  #   ServerSupervisor.whereis
  #   SystemSupervisor.whereis
  #   Logger.configure(level: :error) # allow only error messages
  #   Logger.configure(level: :info ) # allow info/warn/error messages
  #   Logger.configure(level: :debug) # allow all messages (default)

  # Nota bene:
  #   To use Elixir's List, qualify it:
  #   Elixir.List.first(IE.entries)

  defmacro use do
    quote do
      import IE
      alias Todo.List
      alias Todo.List.Cache
      alias Todo.List.Entry
      alias Todo.List.Server
      alias Todo.List.ServerSupervisor
      alias Todo.List.SystemSupervisor
      :ok
    end
  end

  def entries do
    [ %Entry{date: ~D[2016-08-18], title: "vacuum" },
      %Entry{date: ~D[2016-08-20], title: "dusting"},
      %Entry{date: ~D[2016-08-18], title: "laundry"},
      %Entry{date: ~D[2016-08-20], title: "ironing"},
      %Entry{date: ~D[2016-08-19], title: "cooking"},
      %Entry{date: ~D[2016-08-20], title: "baking" }
    ]
  end

  def kill_cache do
    cache = Cache.whereis
    log_error(cache, "being killed")
    Process.exit(cache, :kill) # :kill ensures target taken down
  end

  def kill_server list_name do
    server = Server.whereis list_name
    log_error(server, "being killed")
    Process.exit(server, :kill) # :kill ensures target taken down
  end
end