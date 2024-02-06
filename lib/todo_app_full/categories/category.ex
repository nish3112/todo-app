defmodule TodoAppFull.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  schema "categories" do
    field :category_name, :string
    has_many :todos, TodoAppFull.Todos.Todo
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :body, :status, :liked, :user_id, :category_id])
    |> validate_required([:title, :body, :status, :liked, :user_id, :category_id])
  end
end