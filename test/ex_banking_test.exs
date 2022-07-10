defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create_user -> :ok" do
    assert ExBanking.create_user("User first") == :ok
  end

  test "create_user  -> {:error, :user_already_exists }" do
    assert ExBanking.create_user("TestOne") == :ok
    assert ExBanking.create_user("TestOne") == {:error, :user_already_exists}
  end

  test "create_user -> {:error, :wrong_arguments }" do
    assert ExBanking.create_user(1) == {:error, :wrong_arguments}
  end
end
