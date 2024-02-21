defmodule TodoAppFull.Categories do
  alias TodoAppFull.Repo
  alias TodoAppFull.Categories.Category

  @doc """
  Returns the list of categories.
  """
  def list_categories() do
    Repo.all(Category)
    |> Enum.map(&{&1.category_name, &1.id})
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

end
