defmodule TodoAppFullWeb.TodoLiveTest do
  alias TodoAppFullWeb.ConnCase
  alias TodoAppFull.AccountsFixtures
  use TodoAppFullWeb.ConnCase

  import Phoenix.LiveViewTest
  import TodoAppFull.TodosFixtures
  import TodoAppFull.AccountsFixtures
  import Ecto.UUID

  @create_attrs %{status: "on-hold", title: "some title", body: "some body", liked: true}
  @update_attrs %{
    status: "completed",
    title: "some updated title",
    body: "some updated body",
    liked: false
  }
  @invalid_attrs %{status: "on-hold", title: nil, body: nil, liked: false}
  @subtask_attrs %{"subtask[status]": "on-hold", "subtask[title]": "some subtask title", "subtask[body]": "some subtask body"}
  @subtask_attrs_direct %{status: "on-hold", title: "some direct title", body: "some direct body"}
  @subtask_attrs_for_validation %{"subtask[status]": "on-hold", "subtask[title]": "some subtask title", "subtask[body]": ""}


  # TESTS LEFT -->
             # --> Show - Room join, right side
             # --> Errors



  describe "User not logged in - Always redirected to log in page" do
    setup do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, conn: conn}
    end

    test "User tries to access home page without logging in", %{conn: conn} do
      {:error, {:redirect, %{to: redirect_to}}} = live(conn, ~p"/todos")
      assert redirect_to == "/users/log_in"
    end

    test "User tries to access a todo without logging in", %{conn: conn} do
      random_uuid = "98b88960-b650-4c93-8291-eb7200207db9"
      {:error, {:redirect, %{to: redirect_to}}} = live(conn, ~p"/todos/#{random_uuid}")
      assert redirect_to == "/users/log_in"
    end

    test "User tries to create a new todo without logging in", %{conn: conn} do
      {:error, {:redirect, %{to: redirect_to}}} = live(conn, ~p"/todos/new")
      assert redirect_to == "/users/log_in"
    end

  end

  describe "Index" do
    setup do
      conn = Phoenix.ConnTest.build_conn()
      roles = TodoAppFull.RolesFixtures.insert_roles()
      category = TodoAppFull.CategoryFixtures.insert_categories()
      logged_in_user = ConnCase.register_and_log_in_user(%{conn: conn})

      %{conn: logged_in_user.conn, user: logged_in_user.user, category: category}
    end

    test "User when logged in lands on the listing todos page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/todos")
      html = render(view)
      assert html =~ "Listing Todos"
    end

    test "User creates todo", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view |> element("a", "+") |> render_click() =~ "+"
      assert_patch(view, ~p"/todos/new")

      assert view
             |> form("#todo-form", todo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert view
             |> form("#todo-form", todo: @create_attrs)
             |> render_submit()

      assert_patch(view, ~p"/todos")

      html = render(view)
      assert html =~ "Todo created successfully"
      assert html =~ "some title"
    end

    test "User updates todo", %{conn: conn, user: user, category: category} do
      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)
      {:ok, view, html} = live(conn, ~p"/todos")
      assert html =~ "Title: some title"

      #  TODO CREATED ABOVE
      #  EDIT TODO BELOW

      assert view |> element("a[href='/todos/#{todo.id}/edit']") |> render_click()
      assert view
             |> form("#todo-form", todo: @update_attrs)
             |> render_submit()

      assert_patch(view, ~p"/todos")
      html = render(view)
      assert html =~ "Title: some updated title"

    end


    test "User deletes todo",  %{conn: conn, user: user, category: category} do
      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)
      {:ok, view, html} = live(conn, ~p"/todos")


      anchor_selector = "a[href='#']"
      assert view |> element(anchor_selector) |> render_click()
      {:ok, view, html} = live(conn, ~p"/todos")
      refute has_element?(view, "Title: some title")

    end

    test "User searches todo",  %{conn: conn, user: user, category: category} do
      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)
      {:ok, view, html} = live(conn, ~p"/todos")
      assert html =~ "Title: some title"

      # Checking for a todo that does not exist
      assert view |> has_element?("div.search-bar input[type='search'][name='title'][phx-debounce='500']")
      assert view |> render_change("search", %{"title" => "some title 2"})
      html = render(view)
      refute html =~ "Title: some title"

      # Checking for a todo that exists
      assert view |> has_element?("div.search-bar input[type='search'][name='title'][phx-debounce='500']")
      assert view |> render_change("search", %{"title" => "some title"})
      html = render(view)
      assert html =~ "Title: some title"


    end

    test "User uses bookmarks",  %{conn: conn, user: user, category: category} do
      # CREATE TWO TODOS 1 liked one unliked

      {:ok, view, html} = live(conn, ~p"/todos")

      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)


      category_and_user = %{
        user_id: user.id,
        category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @update_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)

      {:ok, view, html} = live(conn, ~p"/todos")
      assert html =~ "Title: some title"
      assert html =~ "Title: some updated title"
      assert view |> has_element?("div.bookmark button[phx-click='bookmark']")

      assert view  |> element("div.bookmark button[phx-click='bookmark']") |> render_click()

      # The liked one will stay on the page, unliked one wont
      html = render(view)
      refute html =~ "Title: some updated title"
      assert html =~ "Title: some title"

    end

    test "User opens the subtask page (clicks the eye icon)", %{conn: conn, user: user, category: category}  do
      {:ok, view, _html} = live(conn, ~p"/todos")

      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)

      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view |> element("a[href='/todos/#{todo.id}']") |> render_click()
      assert_redirect(view, ~p"/todos/#{todo.id}")

    end

    test "User likes a todo", %{conn: conn, user: user, category: category}  do

      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      todo = TodoAppFull.TodosFixtures.todo_fixture_with_details(todo_attrs)
      IO.inspect(todo)
      {:ok, view, html} = live(conn, ~p"/todos")
      assert view
      |> element("button[phx-click='togglelike']") |> render_click()

      assert view
      |> has_element?("button[phx-click='togglelike'] svg[fill='none']")


    end

    test "User filters something" , %{conn: conn, user: user, category: category} do
      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      todo = TodoAppFull.TodosFixtures.todo_fixture_with_details(todo_attrs)
      IO.inspect(todo)
      {:ok, view, html} = live(conn, ~p"/todos")
      assert html =~ "Title: some title"


      assert view
        |> form("form[phx-submit='sortTodos']", %{
          "status" => "in-progress",
          "category" => "Gaming"
        })
        |> render_submit()

      html = render(view)

      refute html =~ "Title: some title"

      assert view
        |> form("form[phx-submit='sortTodos']", %{
          "category" => "Gaming"
        })
        |> render_submit()

      html = render(view)

      assert html =~ "Title: some title"

    end

    test "User uses pagination", %{conn: conn, user: user, category: category}  do

      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      Enum.each(1..10, fn _ ->
        TodoAppFull.TodosFixtures.todo_fixture_with_details(todo_attrs)
      end)
      {:ok, view, html} = live(conn, ~p"/todos")

      assert view
      |> element("button[phx-click='next']")
      |> render_click()

      html = render(view)
      assert html =~ "Page: 2"

      assert view
      |> element("button[phx-click='previous']")
      |> render_click()

      html = render(view)
      assert html =~ "Page: 1"



    end




  end


  describe "Show" do

    #  |> IO.inspect(limit: :infinity, printable_limit: :infinity, width: 200, label: "HTML:", esc: :unicode)

    setup do
      conn = Phoenix.ConnTest.build_conn()
      roles = TodoAppFull.RolesFixtures.insert_roles()
      category = TodoAppFull.CategoryFixtures.insert_categories()
      logged_in_user = ConnCase.register_and_log_in_user(%{conn: conn})

      # CREATE A BASIC TODO

      [role | _extra] = roles
      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: logged_in_user.user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)

      # ADD THE PERMISSION FOR THE USER
      {:ok, permission} = TodoAppFull.Permissions.create_permission(logged_in_user.user.id, todo.id, role.id)
      %{conn: logged_in_user.conn, todo: todo}
    end


    test "Show pages loads" ,%{conn: conn, todo: todo} do
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert html =~ "Sub todos for todo : some title"
    end


    test "User creates a new subtask",%{conn: conn, todo: todo} do
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert view |> has_element?("a[href='/todos/#{todo.id}/show/new']")
      assert view |> element("a[href='/todos/#{todo.id}/show/new']") |> render_click()
      # subtask_form_data = Map.put(@subtask_attrs, "todo_id", todo.id)

      assert view
             |> form("#subtask-form", @subtask_attrs_for_validation)
             |> render_change() =~ "can&#39;t be blank"

      assert view |> form("#subtask-form", @subtask_attrs) |> render_submit()
      html = render(view)
      assert html=~ "Title: some subtask title"
    end


    test "User updates the subtask", %{conn: conn, todo: todo} do

      #  ON HOLD - Does to render click not available for edit button (we need to use phx-click for it)

      subtask_attrs = Map.put(@subtask_attrs_direct, :todo_id, todo.id)
      {:ok,subtask} = TodoAppFull.Subtasks.create_subtask(subtask_attrs)
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert html =~ "Title: some direct title"
      # IO.inspect(html, limit: :infinity, printable_limit: :infinity, width: 200, label: "HTML:", esc: :unicode)
      assert view |> element("div.sub-todos > div.card-region > div.card") |> render_click()

      #  Click the form without changing anyhing
      assert view
          |> form("#editForm")
          |> render_submit()
    end


    test "User deletes the subtask", %{conn: conn, todo: todo} do
      subtask_attrs = Map.put(@subtask_attrs_direct, :todo_id, todo.id)
      {:ok,subtask} = TodoAppFull.Subtasks.create_subtask(subtask_attrs)
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert html =~ "Title: some direct title"
      assert view |> element("button[phx-click='delete']") |> render_click()
      html = render(view)
      refute html =~ "Title: some direct title"
    end


    test "User opens share permissions modal", %{conn: conn, todo: todo} do
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert view |> element("button[phx-click='shareSubtodos']") |> render_click()
      html = render(view)
      assert html =~ "Users with permission:"

    end

    test "User when clicks on a card its details appear on the right side",  %{conn: conn, todo: todo}  do
      subtask_attrs = Map.put(@subtask_attrs_direct, :todo_id, todo.id)
      {:ok,subtask} = TodoAppFull.Subtasks.create_subtask(subtask_attrs)
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert html =~ "Title: some direct title"

      # MIGHT HAVE TO USE FLOKI -- HOLD
      # document = Floki.parse_document(html)
      # div_element = Floki.find(document, "input#titleInput")




      # assert view |> element("div.sub-todos > div.card-region > div.card") |> render_click()
      # html = render(view)


    end

  end

  describe "Permissions" do

    setup do
      conn = Phoenix.ConnTest.build_conn()
      roles = TodoAppFull.RolesFixtures.insert_roles()
      category = TodoAppFull.CategoryFixtures.insert_categories()
      logged_in_user = ConnCase.register_and_log_in_user(%{conn: conn})
      extra_user = TodoAppFull.AccountsFixtures.user_fixture()


      # CREATE A BASIC TODO

      [role | _extra] = roles
      [first_category | _rest_categories] = category
      category_and_user = %{
                            user_id: logged_in_user.user.id,
                            category_id: elem(first_category, 1)}
      todo_attrs = Map.merge(category_and_user, @create_attrs)
      {:ok,todo} = TodoAppFull.Todos.create_todo(todo_attrs)

      # ADD THE PERMISSION FOR THE USER
      {:ok, permission} = TodoAppFull.Permissions.create_permission(logged_in_user.user.id, todo.id, role.id)
      %{conn: logged_in_user.conn, todo: todo, user1: logged_in_user.user, user2: extra_user}
    end


    test "Creator can grant permission", %{conn: conn, todo: todo, user2: user2} do
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert view |> element("button[phx-click='shareSubtodos']") |> render_click()
      html = render(view)
      assert html =~ "Users with permission:"


      assert view
          |> form("div.permission-form form", %{ "user_email" => user2.email })
          |> render_submit()

      html = render(view)
      assert html =~ user2.email

    end

    test "Creator can update permission", %{conn: conn, todo: todo, user2: user2} do

      # ADD PERMISSION

      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert view |> element("button[phx-click='shareSubtodos']") |> render_click()
      html = render(view)
      assert html =~ "Users with permission:"


      assert view
          |> form("div.permission-form form", %{ "user_email" => user2.email })
          |> render_submit()

      html = render(view)
      assert html =~ user2.email

      # UPDATE IT -- Permission sent again even though user has a permission - iT will update it

      assert view
          |> form("div.permission-form form", %{"user_email" => user2.email })
          |> render_submit()

      html = render(view)


    end

    test "Creator can remove permissions", %{conn: conn, todo: todo, user2: user2} do
      {:ok, view, html} = live(conn, ~p"/todos/#{todo.id}")
      assert view |> element("button[phx-click='shareSubtodos']") |> render_click()
      html = render(view)
      assert html =~ "Users with permission:"

      assert view
          |> form("div.permission-form form", %{ "user_email" => user2.email })
          |> render_submit()

      html = render(view)
      assert html =~ user2.email

      assert view |> element("button[phx-click=remove_permission]") |> render_click()

      html = render(view)
      refute html =~ user2.email

    end
  end


  describe "Error" do

    setup do
      conn = Phoenix.ConnTest.build_conn()
      logged_in_user = ConnCase.register_and_log_in_user(%{conn: conn})

      %{conn: logged_in_user.conn, user: logged_in_user.user}
    end


    test "User enters any random uuid to access todo", %{conn: conn, user: user} do
      random_uuid = Ecto.UUID.generate()
      IO.inspect(random_uuid)
      {:ok, _view, html} = live(conn, "/todos/#{random_uuid}")
      assert html =~ "Unauthorized"
    end

  end




end
