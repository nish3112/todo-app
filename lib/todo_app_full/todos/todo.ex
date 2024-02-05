defmodule TodoAppFull.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :status],
    sortable: [:title, :status],
  }



  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field :status, :string
    field :title, :string
    field :body, :string
    field :liked, :boolean, default: false
    belongs_to :user , TodoAppFull.Accounts.User
    belongs_to :category, TodoAppFull.Categories.Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :body, :status, :liked, :user_id, :category_id])
    |> validate_required([:title, :body, :status, :liked, :user_id, :category_id])
  end
end
