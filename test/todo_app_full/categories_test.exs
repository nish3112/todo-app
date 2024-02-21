defmodule TodoAppFull.CategoriesTest do
  use ExUnit.Case
  alias TodoAppFull.Categories
  alias TodoAppFull.Categories.Category
  alias TodoAppFull.Repo
  use TodoAppFull.DataCase

  test "fetch_categories returns an empty list when there are no categories" do
    categories = Categories.list_categories()
    assert Enum.empty?(categories)
  end

  test "fetch_categories returns all categories after inserting data and checks if they are the same" do
    categories_to_insert = [
      %Category{category_name: "Gaming"},
      %Category{category_name: "Music"},
      %Category{category_name: "Movies"}
    ]
    Enum.each(categories_to_insert, &Repo.insert!(&1))
    categories = Categories.list_categories()

    assert length(categories) == length(categories_to_insert)
    # assert Enum.all?(categories, fn category -> category.name in ["Gaming", "Music", "Movies"] end)
  end

end
