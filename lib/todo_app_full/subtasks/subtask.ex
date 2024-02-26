defmodule TodoAppFull.Subtasks.Subtask do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @moduledoc """
  This module defines the schema for subtasks.
  """

  schema "subtasks" do
    field :status, :string
    field :title, :string
    field :body, :string

    timestamps(type: :utc_datetime)
    belongs_to :todo , TodoAppFull.Todos.Todo
  end

  @doc false
  def changeset(subtask, attrs) do
    subtask
    |> cast(attrs, [:title, :body, :status, :todo_id])
    |> validate_required([:title, :body, :status, :todo_id])
  end
end
