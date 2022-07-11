defmodule ExBankingTest do
  use ExUnit.Case

  test "rate limiter for deposits > 10 " do
    ExBanking.create_user("user 1")

    result = Enum.map(1..13, fn x -> ["user 1", x * 2, "USD"] end) |> Enum.map(fn [name, amount, currency] ->Task.async(fn ->ExBanking.deposit(name, amount, currency)end)end)

    # |> Enum.map(&Task.await/1)

    :timer.sleep(700)

    result1 =
      Enum.map(1..15, fn x -> ["user 1", x * 5, "USD"] end)
      |> Enum.map(fn [name, amount, currency] ->
        Task.async(fn ->
          ExBanking.deposit(name, amount, currency)
        end)
      end)

    result |> Enum.map(&Task.await/1)
    # |>IO.inspect()
    result1 |> Enum.map(&Task.await/1)
    # |> IO.inspect()
    # |> Enum.map(&Task.await/1)

    output = [
      :ok,
      :ok,
      :ok,
      :ok,
      :ok,
      :ok,
      :ok,
      :ok,
      :ok,
      :ok,
      {:error, :too_many_requests_to_user},
      {:error, :too_many_requests_to_user}
    ]

    assert output == result
  end
end
