defmodule TodoAppFull.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field :status, :string
    field :title, :string
    field :body, :string
    field :liked, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :body, :status, :liked])
    |> validate_required([:title, :body, :status, :liked])
  end
end
