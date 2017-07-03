
defmodule Todo.List.ServerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Todo.List.Cache
  alias Todo.List.Entry
  alias Todo.List.Server

  setup do
    entry = %Entry{date: ~D[2016-08-19], title: "dusting"}
    list_name = "housekeeping"
    Cache.server_process list_name
    Server.add_entries list_name, [
      %Entry{date: ~D[2016-08-28], title: "vacuum" },
      %Entry{date: ~D[2016-08-28], title: "laundry"},
      %Entry{date: ~D[2016-08-19], title: "cooking"}
    ]
    on_exit fn -> Server.clear_entries list_name end
    {:ok, list_name: list_name, entry: entry}
  end

  describe "Todo.List.Server.entries/2" do
    test "returns entries for a given date", %{list_name: list_name} do
      assert Server.entries(list_name, ~D[2016-08-28]) == [
        %Entry{id: 1, date: ~D[2016-08-28], title: "vacuum" },
        %Entry{id: 2, date: ~D[2016-08-28], title: "laundry"}
      ]
    end
  end

  describe "Todo.List.Server.add_entry/2" do
    test "adds entry to list", %{list_name: list_name, entry: entry} do
      Server.add_entry(list_name, entry)
      assert Server.entries(list_name, ~D[2016-08-19]) == [
        %Entry{id: 3, date: ~D[2016-08-19], title: "cooking"},
        %Entry{id: 4, date: ~D[2016-08-19], title: "dusting"}
      ]
    end
  end

  describe "Todo.List.Server.delete_entry/2" do
    test "deletes entry from list", %{list_name: list_name} do
      Server.delete_entry(list_name, 2)
      assert Server.entries(list_name, ~D[2016-08-28]) == [
        %Entry{id: 1, date: ~D[2016-08-28], title: "vacuum"}
      ]
    end
  end
end
