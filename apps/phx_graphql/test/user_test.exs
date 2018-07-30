defmodule PhxGraphql.UserTest do
  use ExUnit.Case, async: true
  require Logger

  @moduletag :couchdb
  @user "foo@bar"
  @pass "foobar"
  @company "baz"
  alias PhxGraphql.User

  setup_all do
    {:ok, user} = User.create(%{"username" => @user, "password" => @pass})
    {:ok, [token | _]} = User.add_token(user)
    [user: user, token: token.token]
  end

  describe "user functions" do
    test "create user" do
      {:ok, user} = User.create(%{"username" => @user <> "-test12", "password" => @pass})
      assert user.username == @user <> "-test12"
    end

    test "validate user", context do
      {:ok, user} = User.validate_password(@user, @pass)
      assert user.id == context[:user].id
    end

    test "update user" do
      {:ok, user} = User.validate_password(@user, @pass)
      upd = %{user | company: @company}
      {:ok, update} = User.update(user, upd)
      assert update.company == @company
    end

    test "password update", context do
      user = context[:user]
      new_pw = "test12"
      {:ok, update} = User.pw_update(user, @pass, new_pw)
      {:ok, user1} = User.validate_password(@user, new_pw)
      assert update.id == user1.id
      assert update.id == user.id
      {:ok, _update} = User.pw_update(user, new_pw, @pass)
    end
  end

  describe "token functions" do
    test "add token", context do
      {:ok, [token | _]} = User.add_token(context[:user])
      assert is_binary(token.token)
    end

    test "get token", context do
      {:ok, [token | _]} = User.get_token(context[:user])
      assert is_binary(token.token)
    end

    test "validate token", context do
      {:ok, user1} = User.validate_token(context[:token])
      assert user1.id == context[:user].id
    end
  end
end
