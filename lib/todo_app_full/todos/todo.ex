defmodule TodoAppFull.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @moduledoc """
  This module defines the schema for todos in the TodoAppFull application.
  """

  schema "todos" do
    field :status, :string
    field :title, :string
    field :body, :string
    field :liked, :boolean, default: false
    belongs_to :user , TodoAppFull.Accounts.User
    belongs_to :category, TodoAppFull.Categories.Category
    has_many :subtasks, TodoAppFull.Subtasks.Subtask
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :body, :status, :liked, :user_id, :category_id])
    |> validate_required([:title, :body, :status, :liked, :user_id, :category_id])
  end
end
