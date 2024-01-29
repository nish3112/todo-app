defmodule TodoAppFull.TodosTest do
  use TodoAppFull.DataCase

  alias TodoAppFull.Todos

  describe "todos" do
    alias TodoAppFull.Todos.Todo

    import TodoAppFull.TodosFixtures

    @invalid_attrs %{status: nil, title: nil, body: nil, liked: nil}

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Todos.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Todos.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      valid_attrs = %{status: "some status", title: "some title", body: "some body", liked: true}

      assert {:ok, %Todo{} = todo} = Todos.create_todo(valid_attrs)
      assert todo.status == "some status"
      assert todo.title == "some title"
      assert todo.body == "some body"
      assert todo.liked == true
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      update_attrs = %{status: "some updated status", title: "some updated title", body: "some updated body", liked: false}

      assert {:ok, %Todo{} = todo} = Todos.update_todo(todo, update_attrs)
      assert todo.status == "some updated status"
      assert todo.title == "some updated title"
      assert todo.body == "some updated body"
      assert todo.liked == false
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end
  end
end
