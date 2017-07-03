
defmodule Todo.ListTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Todo.{List, List.Entry}

  doctest List

  setup_all do
    tasks = %{
      right: %Entry{id: 2, date: ~D[2016-08-28], title: "LAUNDRY"},
      wrong: %Entry{id: 4, date: ~D[2016-08-28], title: "LAUNDRY"}
    }
    todos = %{
      old: List.new("housekeeping", [
        Entry.new(date: ~D[2016-08-28], title: "vacuum" ),
        Entry.new(date: ~D[2016-08-28], title: "laundry"),
        Entry.new(date: ~D[2016-08-19], title: "cooking")
      ]),
      new: List.new("housekeeping", [
        Entry.new(date: ~D[2016-08-28], title: "vacuum" ),
        Entry.new(date: ~D[2016-08-28], title: "LAUNDRY"),
        Entry.new(date: ~D[2016-08-19], title: "cooking")
      ])
    }
    {:ok, tasks: tasks, todos: todos}
  end

  describe "Todo.List.update_entry/2" do
    test "update works with valid entry", %{tasks: tasks, todos: todos} do
      assert List.update_entry(todos.old, tasks.right) == todos.new
    end

    test "update ignored if bad id given", %{tasks: tasks, todos: todos} do
      assert List.update_entry(todos.old, tasks.wrong) == todos.old
    end
  end

  describe "Todo.List.update_entry/3" do
    test "update works with valid entry", %{todos: todos} do
      assert List.update_entry(
        todos.old,
        2,
        &Entry.update(&1, title: "#{String.upcase &1.title}")
      ) == todos.new
    end

    test "update ignored if bad id given", %{todos: todos} do
      assert List.update_entry(
        todos.old,
        4,
        &Entry.update(&1, title: "#{String.upcase &1.title}")
      ) == todos.old
    end

    test "update fails if entry id altered", %{todos: todos} do
      assert_raise MatchError, fn ->
        List.update_entry(
          todos.old,
          2,
          &Entry.update(&1, id: &1.id + 1)
        )
      end
    end
  end
end
