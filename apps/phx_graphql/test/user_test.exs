defmodule PhxGraphql.UserTest do
  use ExUnit.Case, async: false

  test "create a user" do
    {:ok, user} = PhxGraphql.User.create(%{"username" => "foo@bar", "password" => "foobar"})
    assert user.username == "foo@bar"
  end
end
