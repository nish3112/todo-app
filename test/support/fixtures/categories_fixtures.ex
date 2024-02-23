defmodule TodoAppFull.CategoryFixtures do
  alias TodoAppFull.Categories
  alias TodoAppFull.Repo

  def insert_categories do
    categories = [
      %{category_name: "Gaming"},
      %{category_name: "Essential"},
      %{category_name: "Coding"}
    ]

    Repo.transaction(fn ->
      Enum.each(categories, &Categories.create_category/1)
    end)

    Categories.list_categories()

  end

end
