defmodule TodoAppFull.SubtasksTest do
  use ExUnit.Case
  alias TodoAppFull.Subtasks
  import TodoAppFull.TodosFixtures
  alias TodoAppFull.SubtasksFixtures
  use TodoAppFull.DataCase

  @invalid_attrs %{status: nil, body: nil, title: nil}

  describe "subtasks" do
    alias TodoAppFull.Subtasks.Subtask

    test "list all the subtasks that belong to a particular user" do
      todo = todo_fixture()
      Subtasks.create_subtask(%{body: "Sample body", status: "pending", title: "Sample title", todo_id: todo.id})
      assert length(Subtasks.list_subtasks(todo.id)) == 1
    end


    test "get_subtask!/1 returns the subtask with given id" do
      subtask = SubtasksFixtures.subtask_fixture()
      assert Subtasks.get_subtask!(subtask.id) == subtask
    end

    test "create_subtask/1 with valid data creates a subtask" do
      todo = TodoAppFull.TodosFixtures.todo_fixture()
      valid_attrs = %{body: "Sample body", status: "pending", title: "Sample title", todo_id: todo.id}

      {:ok, subtask} = Subtasks.create_subtask(valid_attrs)
      assert subtask.status == "pending"
      assert subtask.title == "Sample title"
      assert subtask.body == "Sample body"
    end

    test "create_subtask/1 with invalid data returns error changeset" do
      assert {:error, _changeset} = Subtasks.create_subtask(%{})
    end

    test "update_subtask/2 with valid data updates the subtask" do
      subtask = SubtasksFixtures.subtask_fixture()
      update_attrs = %{status: "completed"}

      {:ok, updated_subtask} = Subtasks.update_subtask(subtask, update_attrs)
      assert updated_subtask.status == "completed"
    end

    test "update_subtask/2 with invalid data returns error changeset" do
      subtask = SubtasksFixtures.subtask_fixture()
      assert {:error, changeset} = Subtasks.update_subtask(subtask, @invalid_attrs)
    end

    test "delete_subtask/1 deletes the subtask" do
      subtask = SubtasksFixtures.subtask_fixture()
      assert {:ok, %Subtask{}} =  Subtasks.delete_subtask(subtask)
      assert_raise Ecto.NoResultsError, fn -> Subtasks.get_subtask!(subtask.id) end
    end

    test "change_subtask/1 returns a subtask changeset" do
      subtask = SubtasksFixtures.subtask_fixture()
      assert %Ecto.Changeset{} = Subtasks.change_subtask(subtask)
    end
  end
end
