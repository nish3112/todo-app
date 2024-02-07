defmodule TodoAppFull.Subtasks do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoAppFull.Repo


  alias TodoAppFull.Subtasks.Subtask

  @doc """
  Returns the list of subtasks for a given todo.

  ## Examples

      iex> list_subtasks(todo_id)
      [%Subtask{}, ...]

  """
  def list_subtasks(todo_id) do
    Subtask
    |> where([s], s.todo_id == ^todo_id)
    |> Repo.all()
  end

  @doc """
  Gets a single subtask.

  Raises `Ecto.NoResultsError` if the Subtask does not exist.

  ## Examples

      iex> get_subtask!(subtask_id)
      %Subtask{}

      iex> get_subtask!(invalid_subtask_id)
      ** (Ecto.NoResultsError)

  """
  def get_subtask!(id) do
    Subtask
    |> Repo.get!(id)
  end

  @doc """
  Creates a subtask for a given todo.

  ## Examples

      iex> create_subtask(%{field: value})
      {:ok, %Subtask{}}

      iex> create_subtask(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subtask(attrs \\ %{}) do
    %Subtask{}
    |> Subtask.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subtask.

  ## Examples

      iex> update_subtask(subtask, %{field: new_value})
      {:ok, %Subtask{}}

      iex> update_subtask(subtask, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subtask(%Subtask{} = subtask, attrs) do
    subtask
    |> Subtask.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subtask.

  ## Examples

      iex> delete_subtask(subtask)
      {:ok, %Subtask{}}

      iex> delete_subtask(subtask)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subtask(%Subtask{} = subtask) do
    Repo.delete(subtask)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subtask changes.

  ## Examples

      iex> change_subtask(subtask)
      %Ecto.Changeset{data: %Subtask{}}

  """
  def change_subtask(%Subtask{} = subtask, attrs \\ %{}) do
    Subtask.changeset(subtask, attrs)
  end
end
