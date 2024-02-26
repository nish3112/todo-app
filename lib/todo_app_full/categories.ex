defmodule TodoAppFull.Categories do

  @moduledoc """

  The TodoAppFull.Categories module manages categories within the TodoAppFull application,
  offering functionality to list existing categories and create new ones.
  Categories are utilized to organize todos within the application.
  The module provides methods to retrieve the list of categories and to create new categories.
  """

  alias TodoAppFull.Repo
  alias TodoAppFull.Categories.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> TodoAppFull.Categories.list_categories()
      [%{category_name: "Work", id: "3fa3d9b3-befa-4e68-9106-536a2b8d302e"}, %{category_name: "Personal", id: "94c059c8-7db7-4772-8a6e-1a6eb09b0094"}]

  """
  def list_categories() do
    Repo.all(Category)
    |> Enum.map(&{&1.category_name, &1.id})
  end


  @doc """
  Creates a new category with the provided attributes.

  ## Parameters
    * `attrs` - A map containing the attributes for the new category -> name of the category.

  ## Examples

      iex> TodoAppFull.Categories.create_category(%{category_name: "Gaming"})
      {:ok, %Category{...}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

end
