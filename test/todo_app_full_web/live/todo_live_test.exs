defmodule TodoAppFullWeb.TodoLiveTest do
  alias TodoAppFullWeb.ConnCase
  alias TodoAppFull.AccountsFixtures
  use TodoAppFullWeb.ConnCase

  import Phoenix.LiveViewTest
  import TodoAppFull.TodosFixtures
  import TodoAppFull.AccountsFixtures

  @create_attrs %{status: "on-hold", title: "some title", body: "some body", liked: true}
  @update_attrs %{status: "some updated status", title: "some updated title", body: "some updated body", liked: false}
  @invalid_attrs %{status: "on-hold", title: nil, body: nil, liked: false}


  describe "User not logged in - Always redirected to log in page" do

    setup do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, conn: conn}
    end


    #  ADD ALL THE TC WHERE THE USER WAS TRYING TO ACCESS A CERTAIN PAGE AND WAS NOT LOGGED IN
    #  HENCE HE WAS REDIRECTED TO THE LOGIN PAGE


  end

  describe "Index" do

    setup do
      conn = Phoenix.ConnTest.build_conn()
      roles = TodoAppFull.RolesFixtures.insert_roles()
      category = TodoAppFull.CategoryFixtures.insert_categories()
      logged_in_user = ConnCase.register_and_log_in_user(%{conn: conn})

      %{conn: logged_in_user.conn}
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

    test "User updates todo",%{conn: conn} do

      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view |> element("a", "+") |> render_click() =~ "+"
      assert view
            |> form("#todo-form", todo: @create_attrs)
            |> render_submit()
      assert_patch(view, ~p"/todos")
      html = render(view)


      # UPDATE CODE -- Solve the above bug --
      # User here and in todo fixture is different so you cannot get the same todo

      {:ok, _, html} = live(conn, ~p"/todos")
      assert html =~ "Title: #{@create_attrs.title}"


      # assert view |> element("a") |> render_click() |> IO.inspect()

      # REMAINING

    end


    test "User deletes todo",%{conn: conn} do

      # {:ok, view, _html} = live(conn, ~p"/todos")

      # assert view |> element("a", "+") |> render_click() =~ "+"
      # assert view
      #       |> form("#todo-form", todo: @create_attrs)
      #       |> render_submit()
      # assert_patch(view, ~p"/todos")
      # html = render(view)
      # delete_link_selector = "a[data-confirm='Are you sure?']"
      # assert view |> element(delete_link_selector) |> render_click()


    end

    test "User searches todo" do

    end

    test "User uses bookmarks" do

    end

    # ADD FILTERS TEST





  end


end
