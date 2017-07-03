
defmodule Todo.List.EntryTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Todo.List.Entry

  doctest Entry

  setup_all do
    tasks = %{
      todo: %Entry{id: 2, date: ~D[2013-12-20], title: "errand"},
      done: %Entry{id: 2, date: ~D[2013-12-20], title: "--errands--",
        status: :done, status_date: ~D[2013-12-19]
      }
    }
    {:ok, tasks: tasks}
  end

  describe "Todo.List.Entry.new/1" do
    test "creates to-do list entry", %{tasks: tasks} do
      assert Entry.new(id: 2, date: ~D[2013-12-20], title: "errand")
      == tasks.todo
    end
  end

  describe "Todo.List.Entry.update/2" do
    test "updates a to-do list entry", %{tasks: tasks} do
      assert Entry.update(
        tasks.todo,
        status: :done,
        status_date: ~D[2013-12-19],
        title: "--#{tasks.todo.title}s--"
      ) == tasks.done
    end
  end
end
