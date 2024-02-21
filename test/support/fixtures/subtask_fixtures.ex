defmodule TodoAppFull.SubtasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Subtask` context.
  """

  @doc """
  Generate a subtask.
  """
  def subtask_fixture(attrs \\ %{}) do
    import TodoAppFull.TodosFixtures
    todo = todo_fixture()

    {:ok, subtask} =
      attrs
      |> Enum.into(%{
        body: "some desc",
        status: "some status",
        title: "some title",
        todo_id: todo.id,
      })
      |> TodoAppFull.Subtasks.create_subtask()

    TodoAppFull.Subtasks.get_subtask!(subtask.id)
  end
end
