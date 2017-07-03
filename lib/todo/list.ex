
defmodule Todo.List do
  @moduledoc """
  Creates and manages a to-do list.
  """

  alias Todo.List
  alias Todo.List.Entry

  defstruct name: nil, auto_id: 1, entries: Map.new

  @type name :: String.t | atom | charlist
  @type t :: %List{
    name: name | nil,
    auto_id: pos_integer | nil,
    entries: map
  }

  @doc """
  Creates a to-do list.

  ## Examples

      iex> alias Todo.List
      iex> List.new(:secret_list)
      %List{name: :secret_list, auto_id: 1, entries: Map.new}

      iex> alias Todo.List
      iex> List.new('cleanup')
      %List{name: 'cleanup', auto_id: 1, entries: Map.new}

      iex> alias Todo.{List, List.Entry}
      iex> entry1 = %Entry{date: ~D[2016-08-18], title: "gym"}
      iex> entry2 = %Entry{date: ~D[2016-08-19], title: "spa"}
      iex> List.new("training", [entry1, entry2])
      %List{
        name: "training", auto_id: 3,
        entries: %{
          1 => %Entry{id: 1, date: ~D[2016-08-18], title: "gym"},
          2 => %Entry{id: 2, date: ~D[2016-08-19], title: "spa"}
        }
      }
  """
  @spec new(name, [Entry.t]) :: t
  def new(name, entries \\ []) do
    Enum.reduce(
      entries,
      %List{name: name},
      &add_entry(&2, &1)
    )
  end

  @doc """
  Adds to-do list entries to a to-do list.

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> entry = %Entry{date: ~D[2016-08-18], title: "mow lawn"}
      iex> list = List.new("gardening", [entry])
      iex> List.add_entries(list, [entry, entry])
      %List{
        name: "gardening", auto_id: 4,
        entries: %{
          1 => %Entry{id: 1, date: ~D[2016-08-18], title: "mow lawn"},
          2 => %Entry{id: 2, date: ~D[2016-08-18], title: "mow lawn"},
          3 => %Entry{id: 3, date: ~D[2016-08-18], title: "mow lawn"}
        }
      }
  """
  @spec add_entries(t, [Entry.t]) :: t
  def add_entries(%List{} = todo, entries \\ []) do
    Enum.reduce(
      entries,
      todo,
      &add_entry(&2, &1)
    )
  end

  @doc """
  Adds a to-do list entry to a to-do list.

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> entry = %Entry{date: ~D[2016-08-18], title: "mow lawn"}
      iex> list = List.new("gardening", [entry])
      iex> List.add_entry(list, entry)
      %List{
        name: "gardening", auto_id: 3,
        entries: %{
          1 => %Entry{id: 1, date: ~D[2016-08-18], title: "mow lawn"},
          2 => %Entry{id: 2, date: ~D[2016-08-18], title: "mow lawn"}
        }
      }
  """
  @spec add_entry(t, Entry.t) :: t
  def add_entry(
    %List{auto_id: auto_id, entries: entries} = todo,
    %Entry{} = entry
  )
  do
    entry = %Entry{entry | id: auto_id}
    entries = Map.put(entries, auto_id, entry)
    %List{todo | auto_id: auto_id + 1, entries: entries}
  end

  @doc """
  Returns a list of to-do list entries for a given date (sorted on id).

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-18], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-18], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.entries(todo, ~D[2016-08-18])
      [ %Entry{id: 1, date: ~D[2016-08-18], title: "vacuum" },
        %Entry{id: 2, date: ~D[2016-08-18], title: "laundry"}
      ]
  """
  @spec entries(t, Date.t) :: [Entry.t]
  def entries(%List{entries: entries}, %Date{} = date) when
    is_map(date) and is_map(entries)
  do
    entries
    |> Stream.filter_map(&elem(&1, 1).date == date, &elem(&1, 1))
    |> Enum.sort(&(&1.id <= &2.id))
  end

  @doc """
  Returns a list of all to-do list entries as maps (sorted by date and id).

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.map_entries(todo)
      [ %{id: 3, date: ~D[2016-08-19], title: "cooking",
          status: nil, status_date: nil
        },
        %{id: 1, date: ~D[2016-08-28], title: "vacuum" ,
          status: nil, status_date: nil
        },
        %{id: 2, date: ~D[2016-08-28], title: "laundry",
          status: nil, status_date: nil
        }
      ]
  """
  @spec map_entries(t) :: [map]
  def map_entries(%List{} = todo) do
    todo
    |> entries
    |> Enum.map(&Map.from_struct/1)
  end

  @doc """
  Returns a list of all to-do list entries as keywords (sorted by date and id).

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.keyword_entries(todo)
      [ [ date: ~D[2016-08-19], id: 3, status: nil, status_date: nil,
          title: "cooking"
        ],
        [ date: ~D[2016-08-28], id: 1, status: nil, status_date: nil,
          title: "vacuum"
        ],
        [ date: ~D[2016-08-28], id: 2, status: nil, status_date: nil,
          title: "laundry"
        ]
      ]
  """
  @spec keyword_entries(t) :: [Keyword.t]
  def keyword_entries(%List{} = todo) do
    todo
    |> map_entries
    |> Enum.map(&Keyword.new/1)
  end

  @doc """
  Returns a list of all to-do list entries (sorted by date and id).

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.entries(todo)
      [ %Entry{id: 3, date: ~D[2016-08-19], title: "cooking"},
        %Entry{id: 1, date: ~D[2016-08-28], title: "vacuum" },
        %Entry{id: 2, date: ~D[2016-08-28], title: "laundry"}
      ]
  """
  @spec entries(t) :: [Entry.t]
  def entries(%List{entries: entries}) when is_map(entries) do
    entries
    |> Map.values
    |> Enum.sort(&(&1.date < &2.date || &1.date == &2.date && &1.id <= &2.id))
  end

  @doc """
  Returns the to-do list entry of a given id or nil.

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.entry(todo, 2)
      %Entry{id: 2, date: ~D[2016-08-28], title: "laundry"}

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   Entry.new(date: ~D[2016-08-28], title: "vacuum")
      ...> ])
      iex> List.entry(todo, 2)
      nil
  """
  @spec entry(t, pos_integer) :: Entry.t | nil
  def entry(%List{entries: entries}, id) when
    is_integer(id) and id > 0 and is_map(entries)
  do
    entries[id]
  end

  @doc """
  Updates a to-do list entry given its replacement.

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> entry = %Entry{id: 2, date: ~D[2016-08-28], title: "LAUNDRY"}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.update_entry(todo, entry)
      %List{
        name: "housekeeping", auto_id: 4,
        entries: %{
          1 => %Entry{id: 1, date: ~D[2016-08-28], title: "vacuum" },
          2 => %Entry{id: 2, date: ~D[2016-08-28], title: "LAUNDRY"},
          3 => %Entry{id: 3, date: ~D[2016-08-19], title: "cooking"}
        }
      }
  """
  @spec update_entry(t, Entry.t) :: t
  def update_entry(%List{} = todo, %Entry{id: id} = entry) when
    is_integer(id) and id >= 1
  do
    update_entry(todo, id, fn _ -> entry end)
  end

  @doc """
  Updates a to-do list entry given its id and an update function.

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> entry = Entry.new(id: 2, date: ~D[2016-08-28], title: "LAUNDRY")
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.update_entry(todo, 2, &(entry || &1))
      %List{
        name: "housekeeping", auto_id: 4,
        entries: %{
          1 => %Entry{id: 1, date: ~D[2016-08-28], title: "vacuum" },
          2 => %Entry{id: 2, date: ~D[2016-08-28], title: "LAUNDRY"},
          3 => %Entry{id: 3, date: ~D[2016-08-19], title: "cooking"}
        }
      }
  """
  @spec update_entry(t, pos_integer, (Entry.t -> Entry.t)) :: t
  def update_entry(%List{entries: entries} = todo, id, update) when
    is_integer(id) and id > 0 and is_function(update, 1) and is_map(entries)
  do
    case entries[id] do
      nil -> todo
      entry ->
        entry = %Entry{id: ^id} = update.(entry) # ensure id unchanged
        entries = %{entries | id => entry}
        %List{todo | entries: entries}
    end
  end

  @doc """
  Deletes a to-do list entry given its id.

  ## Examples

      iex> alias Todo.{List, List.Entry}
      iex> todo = List.new("housekeeping", [
      ...>   %Entry{date: ~D[2016-08-28], title: "vacuum" },
      ...>   %Entry{date: ~D[2016-08-28], title: "laundry"},
      ...>   %Entry{date: ~D[2016-08-19], title: "cooking"}
      ...> ])
      iex> List.delete_entry(todo, 2)
      %List{
        name: "housekeeping", auto_id: 4,
        entries: %{
          1 => %Entry{id: 1, date: ~D[2016-08-28], title: "vacuum" },
          3 => %Entry{id: 3, date: ~D[2016-08-19], title: "cooking"}
        }
      }
  """
  @spec delete_entry(t, pos_integer) :: t
  def delete_entry(%List{entries: entries} = todo, id) when
    is_integer(id) and id > 0 and is_map(entries)
  do
    %List{todo | entries: Map.delete(entries, id)}
  end

  @doc """
  Clears all entries of a to-do list.
  """
  @spec clear_entries(t) :: t
  def clear_entries(%List{name: name}) do
    List.new(name)
  end
end
