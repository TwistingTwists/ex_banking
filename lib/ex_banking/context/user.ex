defmodule ExBanking.User do
  alias ExBanking.User
  # @enforce_keys [:name]

  @doc """
  %User{
    name: "Dhan",
    monies: %{
      "USD" => 60,
      "INR" => 70
    }
  }
  """
  defstruct name: nil, monies: %{}

  def new(user_string) do
    %User{name: user_string, monies: %{}}
  end

  def deposit(user, amount, currency) when amount >= 0 do
    case Map.fetch(user.monies, currency) do
      :error ->
        # currency does not exist yet, create it
        new_monies = Map.put(user.monies, currency, 0.00 + amount)
        {:ok, %{user | monies: new_monies}}

      {:ok, balance} ->
        # common function for deposit or withdraw
        new_monies = Map.put(user.monies, currency, balance + amount)
        {:ok, %{user | monies: new_monies}}
    end
  end

  def withdraw(user, amount, currency) when amount > 0 do
    case Map.fetch(user.monies, currency) do
      :error ->
        {:not_enough_money, user}

      {:ok, balance} ->
        if balance - amount >= 0 do
          new_monies = Map.put(user.monies, currency, balance - amount)
          {:ok, %{user | monies: new_monies}}
        else
          {:not_enough_money, user}
        end
    end
  end

  def get_balance(user, currency) do
    case Map.fetch(user.monies, currency) do
      :error ->
        new_monies = Map.put(user.monies, currency, 0.0)
        {:ok, %{user | monies: new_monies}}

      {:ok, _balance} ->
        {:ok, user}
    end
  end
end
