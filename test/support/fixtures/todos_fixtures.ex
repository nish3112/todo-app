defmodule TodoAppFull.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoAppFull.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        body: "some body",
        liked: true,
        status: "some status",
        title: "some title"
      })
      |> TodoAppFull.Todos.create_todo()

    todo
  end
end
