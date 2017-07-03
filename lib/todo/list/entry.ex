
defmodule Todo.List.Entry do
  @moduledoc """
  Creates and updates a to-do list entry.
  """

  alias Todo.List.Entry

  defstruct id: nil, date: nil, title: nil, status: nil, status_date: nil

  @type t :: %Entry{
    id: pos_integer | nil,
    date: Date.t | nil,
    title: String.t | nil,
    status: atom | nil,
    status_date: Date.t | nil
  }

  @doc """
  Creates a to-do list entry.

  ## Examples

      iex> alias Todo.List.Entry
      iex> Entry.new(date: ~D[2013-12-20], title: "work", title: "rest")
      %Entry{date: ~D[2013-12-20], title: "rest"}
  """
  @spec new(Keyword.t) :: t
  def new(opts \\ []), do: update(%Entry{}, opts)

  @doc """
  Updates a to-do list entry.

  ## Examples

      iex> alias Todo.List.Entry
      iex> entry = Entry.new(date: ~D[2013-12-20], title: "shopping")
      iex> Entry.update(entry, status: :todo)
      %Entry{date: ~D[2013-12-20], status: :todo, title: "shopping"}
  """
  @spec update(t, Keyword.t) :: t
  def update(%Entry{} = entry, opts \\ []) do
    Enum.reduce(
      opts,
      entry,
      &Map.put(&2, elem(&1, 0), elem(&1, 1))
    )
  end
end
