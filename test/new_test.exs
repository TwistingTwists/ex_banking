defmodule NewTest do
  def call do
    ExBanking.create_user("user 1")

    result =
      Enum.map(1..13, fn x -> ["user 1", x * 2, "USD"] end)
      |> Enum.map(fn [name, amount, currency] ->
        Task.async(fn -> ExBanking.deposit(name, amount, currency) end)
      end)

    # |> Enum.map(&Task.await/1)

    :timer.sleep(700)

    result1 =
      Enum.map(1..15, fn x -> ["user 1", x * 5, "USD"] end)
      |> Enum.map(fn [name, amount, currency] ->
        Task.async(fn ->
          ExBanking.deposit(name, amount, currency)
        end)
      end)

    result =
      result
      |> Enum.map(&Task.await/1)

    result1 = result1 |> Enum.map(&Task.await/1)
    result ++ result1
  end

  def withdraw_test do
    ExBanking.create_user("jon")
    ExBanking.deposit("jon", 100, "USD")
    ExBanking.deposit("jon", 1000, "INR")

    ExBanking.withdraw("jon", 10, "USD")
    ExBanking.withdraw("jon", 1000, "USD")
    ExBanking.withdraw("jon", 10, "EUR")
    ExBanking.withdraw("joyn", 10, "INR")
  end

  def via(name) do
    {:via, Registry, {ExBanking.Registry.User, name}}
  end

  def get_balance do
    ExBanking.create_user("jon")
    ExBanking.deposit("jon", 100, "USD")
    ExBanking.deposit("jon", 1000, "INR")

    ExBanking.withdraw("jon", 10, "USD")
    ExBanking.withdraw("jon", 1000, "USD")

    ExBanking.get_balance("jon", "USD")
    ExBanking.get_balance("jon", "INR")
    ExBanking.get_balance("jon", "YEN")
  end

  def send do
    ExBanking.create_user("jon")
    ExBanking.create_user("absek")
    ExBanking.deposit("jon", 100, "USD")
    ExBanking.deposit("jon", 200, "INR")
    ExBanking.deposit("absek", 1000, "USD")
    ExBanking.deposit("absek", 2000, "INR")

    ExBanking.get_balance("jon", "USD")
    ExBanking.get_balance("jon", "INR")

    ExBanking.get_balance("absek", "USD")
    ExBanking.get_balance("absek", "INR")

    ExBanking.send("jon", "absek", 100, "INR")
    ExBanking.send("jon", "absek", 1000, "INR")
    ExBanking.send("jon", "absek", 100, "USD")
    ExBanking.send("absek", "jon", 100, "USD")
    ExBanking.send("absek", "jon", 100, "INR")

    ExBanking.send("aabsek", "jon", 100, "USD")
    ExBanking.send("absek", "jaon", 100, "INR")

    ExBanking.send("absek", "jon", 100, "lasf")
    ExBanking.send("absek", "jon", 100, "INR")
  end

  # GenServer.call(NewTest.via("jon"), {:deposit, 100, "USD"})
end
