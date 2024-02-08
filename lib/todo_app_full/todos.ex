defmodule TodoAppFull.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoAppFull.Repo

  alias TodoAppFull.Todos.Todo



  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos(u_id) do
    IO.inspect(u_id)
    Todo
        |> where([t], (t.user_id == ^u_id))
        |> Repo.preload([:category, :subtasks])
        |> Repo.all()
  end

  # def list_todos(params) do
  #   case Flop.validate_and_run(Todo, params, for: Todo) do
  #     {:ok, {todos, meta}} ->
  #       %{todos: todos, meta: meta}
  #     {:error, meta} ->
  #       %{todos: [], meta: meta}
  #   end
  # end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id) do
    todo = Todo
    |> Repo.get!(id)
    |> Repo.preload([:category, :subtasks])
    dbg(todo)
    todo
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Repo.preload(:category)
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    dbg(todo)
    dbg(attrs)
    todo
    |> Repo.preload(:category)
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
