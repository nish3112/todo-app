defmodule TodoAppFull.CategoryFixtures do
  alias TodoAppFull.Categories
  alias TodoAppFull.Repo

  def insert_categories do
    categories = [
      %{category_name: "Work"},
      %{category_name: "Personal"},
      %{category_name: "Shopping"}
      # Add more categories as needed
    ]

    Repo.transaction(fn ->
      Enum.each(categories, &Categories.create_category/1)
    end)
  end

end
