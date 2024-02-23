defmodule TodoAppFull.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoAppFull.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, user} = TodoAppFull.Accounts.register_user(%{email: "test@example.com", password: "password@1234567"})
    {:ok,category} = TodoAppFull.Categories.create_category(%{category_name: "Test Category"})

    {:ok, todo} =
      attrs
      |> Enum.into(%{
        body: "some body",
        liked: true,
        status: "some status",
        title: "some title",
        user_id: user.id,
        category_id: category.id
      })
      |> TodoAppFull.Todos.create_todo()


    # todo
    TodoAppFull.Todos.get_todo!(todo.id)
  end


  def todo_fixture_with_details(attrs) do

    {:ok, todo} =
      attrs
      |> Enum.into(%{
        body: attrs.body,
        liked: attrs.liked,
        status: attrs.status,
        title: attrs.title,
        user_id: attrs.user_id,
        category_id: attrs.category_id
      })
      |> TodoAppFull.Todos.create_todo()


    # todo
    TodoAppFull.Todos.get_todo!(todo.id)
  end

end
