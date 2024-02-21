defmodule TodoAppFullWeb.PageControllerTest do
  use TodoAppFullWeb.ConnCase
  import TodoAppFull.AccountsFixtures
  setup do
    user = user_fixture()
    conn = build_conn()
    conn_with_user = log_in_user(conn, user)
    %{user: user, conn: conn_with_user}
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert conn.status == 200
  end
end
