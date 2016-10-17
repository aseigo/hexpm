defmodule HexWeb.PasswordControllerTest do
  use HexWeb.ConnCase, async: true
  alias HexWeb.Auth
  alias HexWeb.User

  setup do
    %{user: create_user("eric", "eric@mail.com", "hunter42")}
  end

  test "show select new password", c do
    conn = get(build_conn(), "password/new", %{"username" => c.user.username, "key" => "RESET_KEY"})
    assert conn.status == 200
    assert conn.resp_body =~ "Choose a new password"
    assert conn.resp_body =~ "RESET_KEY"
  end

  test "submit new password", c do
    assert {:ok, {%User{username: "eric"}, _, _}} = Auth.password_auth("eric", "hunter42")

    # initiate password reset (usually done via api)
    user = User.password_reset(c.user) |> HexWeb.Repo.update!

    # chose new password (using token) to `abcd1234`
    conn = post(build_conn(), "password/new", %{"username" => user.username, "key" => user.reset_key, "password" => "abcd1234"})
    assert conn.status == 200
    assert conn.assigns.success == true

    # check new password will work
    assert {:ok, {%User{username: "eric"}, _, _}} = Auth.password_auth("eric", "abcd1234")
  end
end
