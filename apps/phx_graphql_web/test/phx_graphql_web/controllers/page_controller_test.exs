defmodule PhxGraphqlWeb.PageControllerTest do
  use PhxGraphqlWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "This is PhxGraphql"
  end
end
